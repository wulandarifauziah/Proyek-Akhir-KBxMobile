# import json
# from django.http import JsonResponse
# from django.views.decorators.csrf import csrf_exempt
# from api.model.inference import Model
# from io import BytesIO

# model = Model.from_path('api/model/garden/mineral_model.tflite')
# model = Model.from_path(MODEL_PATH)

# @csrf_exempt
# def predict(request):
#     if request.method == 'POST':
#         try:
#             data = json.loads(request.body.decode('utf-8'))
#             user_data = data.get('data')

#             if user_data is None:
#                 return JsonResponse({'error': 'No data provided'}, status=400)
            
#             prediction = model.predict_from_data(user_data)

#             return JsonResponse({'message': 'Data received', 'prediction': prediction}, status=200)
#         except json.JSONDecodeError:
#             return JsonResponse({'error': 'Invalid JSON format'}, status=400)
#     else:
#         return JsonResponse({'error': 'This endpoint only supports POST requests.'}, status=405)
    
# @csrf_exempt
# def predict_image(request):
#     if request.method == 'POST':
#         try:
#             image = request.FILES.get('image')

#             if image is None:
#                 return JsonResponse({'error': 'No image provided in "image" field'}, status=400)
            
#             image.seek(0)
#             image_data_stream = BytesIO(image.read())
            
#             prediction = model.predict_from_image(image)

#             return JsonResponse({'message': 'Image received', 'prediction': prediction}, status=200)
#         except json.JSONDecodeError:
#             return JsonResponse({'error': 'Invalid JSON format'}, status=400)
#     else:
#         return JsonResponse({'error': 'This endpoint only supports POST requests.'}, status=405)
# views.py (KODE FINAL DAN BENAR)

import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from io import BytesIO # ⬅️ Wajib ada!
from api.model.inference import Model 

# --- LANGKAH 1: Pastikan Path Model Benar ---
# Pastikan path ini SAMA PERSIS dengan lokasi file mineral_model.tflite Anda.
MODEL_PATH = 'api/model/garden/mineral_model.tflite'

# Initialize model with error handling
model = None
try:
    model = Model.from_path(MODEL_PATH)
    print(f"✅ Model loaded successfully from {MODEL_PATH}")
except Exception as e:
    print(f"❌ Error loading model: {str(e)}")
# ---

@csrf_exempt
def predict(request):
    # ... (Biarkan endpoint predict untuk data tabular seperti sebelumnya)
    if request.method == 'POST':
        try:
            data = json.loads(request.body.decode('utf-8'))
            user_data = data.get('data')

            if user_data is None:
                return JsonResponse({'error': 'No data provided'}, status=400)
            
            prediction = model.predict_from_data(user_data)

            return JsonResponse({'message': 'Data received', 'prediction': prediction}, status=200)
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON format'}, status=400)
    else:
        return JsonResponse({'error': 'This endpoint only supports POST requests.'}, status=405)
    
@csrf_exempt
def predict_image(request):
    if request.method == 'POST':
        try:
            # Check if model was loaded
            if model is None:
                return JsonResponse({'error': 'Model failed to load. Check server logs.'}, status=500)
            
            image = request.FILES.get('image')

            if image is None:
                return JsonResponse({'error': 'No image provided in "image" field'}, status=400)
            
            # ⬅️ PERBAIKAN KRITIS 1: Menggunakan BytesIO untuk PIL.Image.open()
            image.seek(0)
            image_data_stream = BytesIO(image.read())
            
            # Memanggil fungsi prediksi gambar
            prediction = model.predict_from_image(image_data_stream)

            # ⬅️ PERBAIKAN KRITIS 2: Cek Error String DENGAN memastikan tipe data
            # Cek jika item pertama adalah string yang dimulai dengan "ERROR"
            if isinstance(prediction[0], str) and prediction[0].startswith("ERROR"):
                 return JsonResponse({'error': prediction[0]}, status=500)

            # ⬅️ PERBAIKAN KRITIS 3: Mengembalikan Dictionary Hasil Prediksi
            # prediction[0] adalah dictionary hasil prediksi yang sukses
            return JsonResponse(prediction[0], status=200) 
            
        except Exception as e: 
            # Tangkap semua exception lainnya
            return JsonResponse({'error': f'Server processing error during image prediction: {str(e)}'}, status=500)
    else:
        return JsonResponse({'error': 'This endpoint only supports POST requests.'}, status=405)