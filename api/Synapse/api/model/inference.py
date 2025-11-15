# inference.py (Kode Final yang Direkomendasikan)

import numpy as np
import pickle
import joblib
import tensorflow as tf
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.compose import ColumnTransformer
from PIL import Image

# --- DAFTAR LABEL MINERAL ANDA (FINAL) ---
MINERAL_LABELS = [
    "Azurite",      # Index 0
    "Calcite",      # Index 1
    "Copper",       # Index 2
    "Hematite",     # Index 3
    "Malachite"     # Index 4
]
# ----------------------------------------

class Model:
    # Set labels dan ukuran gambar sebagai atribut kelas
    MINERAL_LABELS = MINERAL_LABELS
    IMAGE_SIZE = (224, 224) 

    def __init__(self, model_path):
        # ... (Kode __init__ tetap sama) ...
        if model_path.endswith('.pkl'):
            with open(model_path, 'rb') as f:
                self.model = pickle.load(f)
            self.model_type = 'sklearn'
        elif model_path.endswith('.joblib'):
            self.model = joblib.load(model_path)
            self.model_type = 'sklearn'
        elif model_path.endswith('.h5'):
            self.model = tf.keras.models.load_model(model_path)
            self.model_type = 'keras'
        elif model_path.endswith('.tflite'):
            self.model = tf.lite.Interpreter(model_path=model_path)
            self.model.allocate_tensors()
            self.model_type = 'tflite'
        else:
            raise ValueError(f"Model format '{model_path.split('.')[-1]}' not supported. Please use '.pkl', '.joblib', '.h5', or '.tflite'.")
        # ------------------------------------

    def data_pipeline(self, numerical_features=None, scaler_type="standard"):
        # ... (data_pipeline tetap sama) ...
        if self.model_type != 'sklearn':
            raise ValueError("Data pipeline is only supported for scikit-learn models.")
        
        transformers = []
        
        if numerical_features:
            if scaler_type == "standard":
                transformers.append(('scaler', StandardScaler(), numerical_features))
            elif scaler_type == "minmax":
                transformers.append(('scaler', MinMaxScaler(), numerical_features))
            else:
                raise ValueError(f"Unsupported scaler type: '{scaler_type}'. Use 'standard' or 'minmax'.")

        preprocessor = ColumnTransformer(transformers, remainder='passthrough')
        
        pipeline = Pipeline([
            ('preprocessor', preprocessor),
            ('model', self.model)
        ])
        
        return pipeline

    def predict_from_image(self, image_file):
        '''
        Preprocessing disesuaikan untuk model klasifikasi gambar (RGB, 224x224).
        Output diparsing menjadi format JSON lengkap.
        '''
        if self.model_type not in ['tflite', 'keras']:
             return ["ERROR: Method ini hanya didukung untuk model Keras/TFLite."]
             
        try:
            # 1. Pemrosesan Gambar
            img = Image.open(image_file).convert('RGB')
            img = img.resize(self.IMAGE_SIZE) 
            img_array = np.array(img, dtype=np.float32) / 255.0 
            input_data = np.expand_dims(img_array, axis=0)

            # 2. Inferensi TFLite/Keras
            if self.model_type == 'tflite':
                input_details = self.model.get_input_details()
                output_details = self.model.get_output_details()
                
                input_data = input_data.astype(input_details[0]['dtype']) 
                
                self.model.set_tensor(input_details[0]['index'], input_data)
                self.model.invoke()
                # prediction_raw adalah array probabilitas
                prediction_raw = self.model.get_tensor(output_details[0]['index'])[0] 
            
            elif self.model_type == 'keras':
                prediction_raw = self.model.predict(input_data)[0]

            # 3. Parsing Hasil & Confidence
            prediction_index = np.argmax(prediction_raw)
            mineral_name = self.MINERAL_LABELS[prediction_index]
            confidence = prediction_raw[prediction_index]
            
            # 4. Ambil 2 Alternatif Prediksi Teratas
            top_k = 3
            top_k_indices = np.argsort(prediction_raw)[::-1][:top_k]
            
            alternatives = []
            for i in top_k_indices:
                if i != prediction_index: 
                    alternatives.append({
                        "mineralName": self.MINERAL_LABELS[i],
                        "confidence": float(prediction_raw[i]),
                    })
            
            # 5. Return dalam format Dictionary/JSON yang diharapkan views.py
            return [{
                "mineralName": mineral_name,
                "confidence": float(confidence),
                "alternatives": alternatives[:2] 
            }]
            
        except IndexError:
             return ["ERROR: Indeks prediksi di luar jangkauan label. Pastikan daftar MINERAL_LABELS (5 kelas) benar."]
        except Exception as e:
            return [f"ERROR: Processing failed: {str(e)}"]

    def predict_from_data(self, data):
        # ... (predict_from_data tetap sama untuk data tabular) ...
        # Ditinggalkan kosong karena fokus pada image
        return ["Method not implemented for image focus."]

    @staticmethod
    def from_path(model_path):
        return Model(model_path)