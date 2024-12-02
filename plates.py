import os
import cv2
import numpy as np
import matplotlib.pyplot as plt
import tkinter as tk
from tkinter import filedialog
from skimage.filters import threshold_otsu, sobel
from skimage.morphology import remove_small_objects, dilation, square
from skimage import measure
import pickle

def training_images():
    """
    Función para procesar y guardar las imágenes de entrenamiento junto con sus etiquetas.
    Guarda los datos en un archivo 'imagefilldata.pkl'.
    """
    train_dir = "LettsAndNums_TrainModel"
    if not os.path.exists(train_dir):
        print(f"Directorio '{train_dir}' no encontrado.")
        return

    file_names = os.listdir(train_dir)
    # Filtrar archivos ocultos o no deseados
    file_names = [f for f in file_names if not f.startswith('.')]
    
    images = []
    labels = []
    
    for file in file_names:
        img_path = os.path.join(train_dir, file)
        img = cv2.imread(img_path, cv2.IMREAD_GRAYSCALE)
        if img is None:
            print(f"No se pudo leer la imagen: {img_path}")
            continue
        # Redimensionar la imagen para uniformidad
        img_resized = cv2.resize(img, (24, 42))
        images.append(img_resized)
        label = file[0]  # Suponiendo que el primer carácter es la etiqueta
        labels.append(label)
    
    # Guardar las imágenes y etiquetas usando pickle
    with open("imagefilldata.pkl", "wb") as f:
        pickle.dump({'images': images, 'labels': labels}, f)
    
    print("Datos de entrenamiento guardados en 'imagefilldata.pkl'.")

def main_menu():
    """
    Función principal que crea la interfaz gráfica para seleccionar una imagen.
    """
    root = tk.Tk()
    root.title("Detector de Placas")
    root.geometry("300x300")
    
    label = tk.Label(root, text="¡Bienvenido al detector de placas!\nSeleccione un archivo:", wraplength=250, font=("Helvetica", 12))
    label.pack(pady=50)
    
    btn = tk.Button(root, text="Seleccionar", command=lambda: plot_button_pushed(root))
    btn.pack()
    
    root.mainloop()

def plot_button_pushed(root):
    """
    Función que se ejecuta al presionar el botón 'Seleccionar'.
    Permite al usuario elegir una imagen y realiza el procesamiento para detectar la placa.
    """
    # Abrir diálogo para seleccionar archivo
    file_path = filedialog.askopenfilename(title="Seleccionar una imagen", 
                                           filetypes=[("Archivos de imagen", "*.jpg *.jpeg *.png *.bmp")])
    if not file_path:
        print("El usuario canceló la selección de archivo.")
        return
    
    # Cerrar todas las figuras de matplotlib abiertas
    plt.close('all')
    
    # Leer y mostrar la imagen original redimensionada
    img = cv2.imread(file_path, cv2.IMREAD_GRAYSCALE)
    if img is None:
        print(f"No se pudo leer la imagen: {file_path}")
        return
    disp_img = cv2.resize(img, (500, 300))
    plt.figure()
    plt.imshow(disp_img, cmap='gray')
    plt.title("Imagen Original")
    plt.axis('off')
    
    # Aplicar filtro mediano para reducir el ruido
    img_filtered = cv2.medianBlur(img, 3)
    
    # Aplicar filtro gaussiano
    img_filtered = cv2.GaussianBlur(img_filtered, (5,5), 4)
    
    # Redimensionar la imagen filtrada
    img_resized = cv2.resize(img_filtered, (500, 300))
    h, w = img_resized.shape
    
    # Binarizar la imagen usando el umbral de Otsu
    thresh_val = threshold_otsu(img_resized)
    binary_image = img_resized > thresh_val
    reverse = np.invert(binary_image)
    
    # Mostrar la imagen binarizada
    plt.figure()
    plt.imshow(reverse, cmap='gray')
    plt.title("Imagen Binarizada y Filtrada")
    plt.axis('off')
    
    # Remover objetos pequeños
    if w > 2000:
        temp = remove_small_objects(reverse, min_size=3500)
    else:
        temp = remove_small_objects(reverse, min_size=3000)
    
    # Mostrar la imagen después de remover objetos pequeños
    plt.figure()
    plt.imshow(temp, cmap='gray')
    plt.title("Elementos No Deseados Eliminados")
    plt.axis('off')
    
    # Restar los objetos no deseados de la imagen original binarizada
    temp2 = reverse & ~temp
    temp2 = remove_small_objects(temp2, min_size=250)
    
    # Detección de bordes usando el operador de Sobel
    edges = sobel(temp2)
    edges_binary = edges > 0.1  # Umbral para binarizar los bordes
    
    # Dilatar los bordes para conectar componentes
    struct_elem = cv2.getStructuringElement(cv2.MORPH_RECT, (2,1))  # Elemento estructurante lineal
    dilated = cv2.dilate(edges_binary.astype(np.uint8), struct_elem, iterations=1)
    
    # Mostrar la imagen con bordes detectados
    plt.figure()
    plt.imshow(dilated, cmap='gray')
    plt.title("Bordes Detectados")
    plt.axis('off')
    
    # Cargar datos de entrenamiento
    try:
        with open("imagefilldata.pkl", "rb") as f:
            data = pickle.load(f)
    except FileNotFoundError:
        print("Archivo 'imagefilldata.pkl' no encontrado. Ejecuta 'training_images()' primero.")
        return
    images = data['images']
    labels = data['labels']
    
    # Etiquetar componentes conectados
    labeled = measure.label(dilated, connectivity=2)
    props = measure.regionprops(labeled)
    
    # Dibujar cuadros delimitadores en la imagen original
    fig, ax = plt.subplots()
    ax.imshow(disp_img, cmap='gray')
    for prop in props:
        minr, minc, maxr, maxc = prop.bbox
        rect = plt.Rectangle((minc, minr), maxc - minc, maxr - minr, 
                             edgecolor='yellow', linewidth=2, fill=False)
        ax.add_patch(rect)
    ax.set_title("Caracteres Detectados")
    plt.axis('off')
    
    # Inicializar la cadena de la placa
    plate = ""
    
    for prop in props:
        minr, minc, maxr, maxc = prop.bbox
        char_img = reverse[minr:maxr, minc:maxc]
        if char_img.size == 0:
            continue
        # Redimensionar el carácter a 24x42
        char_img = cv2.resize(char_img.astype(np.uint8)*255, (24,42))
        
        # Normalizar las imágenes
        char_img = char_img / 255.0
        char_flat = char_img.flatten()
        
        correlations = []
        for train_img in images:
            train_resized = train_img / 255.0
            train_flat = train_resized.flatten()
            # Calcular el coeficiente de correlación
            if np.std(char_flat) == 0 or np.std(train_flat) == 0:
                corr = 0
            else:
                corr = np.corrcoef(char_flat, train_flat)[0,1]
            correlations.append(corr)
        
        max_corr = max(correlations)
        if max_corr > 0.5:
            max_index = correlations.index(max_corr)
            final_char = labels[max_index]
            plate += final_char
    
    # Mostrar todas las imágenes procesadas en subplots
    plt.figure(figsize=(10,8))
    plt.subplot(2,2,1)
    plt.imshow(disp_img, cmap='gray')
    plt.title("Imagen Original")
    plt.axis('off')
    
    plt.subplot(2,2,2)
    plt.imshow(reverse, cmap='gray')
    plt.title("Imagen Binarizada y Filtrada")
    plt.axis('off')
    
    plt.subplot(2,2,3)
    plt.imshow(temp, cmap='gray')
    plt.title("Elementos No Deseados Eliminados")
    plt.axis('off')
    
    plt.subplot(2,2,4)
    plt.imshow(dilated, cmap='gray')
    plt.title("Bordes Detectados")
    plt.axis('off')
    
    plt.tight_layout()
    plt.show()
    
    # Imprimir la placa detectada
    print("Placas Detectadas:", plate)
    
    # Cerrar la ventana de la GUI
    root.destroy()

if __name__ == "__main__":
    # Ejecutar la función de entrenamiento y luego la interfaz principal
    training_images()
    main_menu()
