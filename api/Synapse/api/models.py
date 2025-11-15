import numpy as np
import pandas as pd
import pickle
import joblib
import tensorflow as tf
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler, MinMaxScaler
from sklearn.compose import ColumnTransformer
from PIL import Image

MINERAL_LABELS = [
    "Azurite", 
    "Calcite", 
    "Copper", 
    "Hematite", 
    "Malachite",
]
IMAGE_SIZE = (224, 224) 
TOP_N_ALTERNATIVES = 5 

class Model:
    def __init__(self, model_path):
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

    def data_pipeline(self, numerical_features=None, scaler_type="standard"):
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
        ], memory=None)
        
        return pipeline

    def predict_from_image(self, image_file):
        image = Image.open(image_file).convert('RGB') 
        image = image.resize(IMAGE_SIZE) 
        
        image_array = np.array(image, dtype=np.float32) / 255.0

        if image_array.ndim == 3:
             image_array = np.expand_dims(image_array, axis=0)

        prediction_probabilities = None

        if self.model_type == 'keras':
            prediction_probabilities = self.model.predict(image_array)[0] 

        elif self.model_type == 'tflite':
            input_details = self.model.get_input_details()
            output_details = self.model.get_output_details()
            
            image_array = image_array.astype(input_details[0]['dtype']) 
            self.model.set_tensor(input_details[0]['index'], image_array)
            self.model.invoke()

            prediction_probabilities = self.model.get_tensor(output_details[0]['index'])[0]
        
        else:
            raise ValueError("This method is only supported for Keras and TensorFlow Lite models.")

        top_indices = np.argsort(prediction_probabilities)[::-1]

        main_index = top_indices[0]
        mineral_name = MINERAL_LABELS[main_index]
        confidence = float(prediction_probabilities[main_index])

        alternatives = []
        for i in range(1, min(TOP_N_ALTERNATIVES + 1, len(top_indices))):
            alt_index = top_indices[i]
            alternatives.append({
                'mineralName': MINERAL_LABELS[alt_index],
                'confidence': float(prediction_probabilities[alt_index]),
            })

        return {
            'mineralName': mineral_name,
            'confidence': confidence,
            'alternatives': alternatives,
        }

    def _predict_sklearn(self, data):
        if isinstance(data, (list, np.ndarray)):
            data = pd.DataFrame([data])
        elif not isinstance(data, pd.DataFrame):
            raise ValueError("Data format not supported for sklearn model. Use list, NumPy array, or DataFrame.")
        
        prediction = self.model.predict(data)
        return prediction.tolist() if isinstance(prediction, np.ndarray) else str(prediction)

    def _predict_keras(self, data):
        '''Predict using Keras model (for tabular data).'''
        data = np.array(data, dtype=np.float32)
        if data.ndim == 1:
            data = data.reshape(1, -1)
        prediction = self.model.predict(data)
        return prediction.tolist()

    def _predict_tflite(self, data):
        input_details = self.model.get_input_details()
        output_details = self.model.get_output_details()
        
        data = np.array(data, dtype=input_details[0]['dtype'])
        if data.ndim == 1:
            data = np.expand_dims(data, axis=0)
        self.model.set_tensor(input_details[0]['index'], data)
        self.model.invoke()
        prediction = self.model.get_tensor(output_details[0]['index'])
        return prediction.tolist()

    def predict_from_data(self, data, numerical_features=None):
        if self.model_type == 'sklearn':
            return self._predict_sklearn(data)
        elif self.model_type == 'keras':
            return self._predict_keras(data)
        elif self.model_type == 'tflite':
            return self._predict_tflite(data)
        else:
            raise ValueError("Model type not supported.")
        
    @staticmethod
    def from_path(model_path):
        return Model(model_path)