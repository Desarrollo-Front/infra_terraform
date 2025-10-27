# 🏗️ Infraestructura Frontend con Terraform

Este proyecto contiene la configuración de **infraestructura como código (IaC)** desarrollada en **Terraform** para desplegar y administrar los recursos necesarios del **frontend** del proyecto de *Desarrollo de Aplicaciones 2*.


## 🚀 Objetivo

Automatizar la creación y configuración de los servicios en **AWS** que permiten alojar y distribuir la aplicación frontend de forma segura, escalable y con alta disponibilidad.


## 🧱 Componentes principales

### 🌐 **Amazon S3**
- Bucket configurado para hosting estático del sitio web.
- Políticas de acceso y versionado.
- Bloqueo de acceso público configurado según buenas prácticas.

### ☁️ **Amazon CloudFront**
- CDN configurada como *distribution* para servir el contenido del bucket S3.
- Origin Access Control (OAC) para restringir el acceso directo al S3.
- Mejora del rendimiento global mediante caché y HTTPS.

### 🔐 **Backend remoto**
- Uso de un `backend.hcl` para almacenar el *state file* de Terraform en un bucket remoto.
- Permite trabajo colaborativo y evita inconsistencias en el estado local.


## 📂 Estructura del proyecto
```
infra_terraform/
│
├── infra/
│ ├── bootstrap/
│ │ └── main.tf # Crea el bucket inicial para almacenar el state remoto
│ └── main/
│ ├── backend.hcl # Configuración del backend remoto
│ ├── cloudfront.tf # Recursos de CloudFront (CDN)
│ └── main.tf # Recursos principales (S3, IAM, etc.)
│
├── .gitignore # Archivos y carpetas ignoradas (.terraform/, tfstate, etc.)
└── README.md # Documentación del proyecto
```


## ⚙️ Comandos principales

🔧 Inicializar el entorno

terraform init -backend-config=infra/main/backend.hcl

🧩 Previsualizar los cambios

terraform plan

🚀 Aplicar la infraestructura

terraform apply -auto-approve

🧹 Destruir los recursos (si es necesario)

terraform destroy -auto-approve

🧾 Resultados esperados

Al ejecutar correctamente los scripts de Terraform, se generan los siguientes outputs:

    frontend_website_url → URL del hosting en S3.

    cloudfront_url → URL de distribución global con HTTPS.

Ejemplo:

frontend_website_url = "manu-frontend-website-32010f8f.s3-website-us-east-1.amazonaws.com"
cloudfront_url       = "d1z225x06rco7j.cloudfront.net"

🧠 Aprendizajes y buenas prácticas

    Uso de IaC (Infrastructure as Code) para reproducir entornos fácilmente.

    Separación de fases bootstrap y main para gestionar el backend remoto.

    Manejo de variables sensibles y buenas prácticas con .gitignore.

    Comprensión de la relación entre S3, CloudFront, y Origin Access Control.
