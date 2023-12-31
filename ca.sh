#!/bin/bash
#set -x
#sudo apt install openvpn y easy-rsa

# Función para solicitar datos de la CA
solicitar_datos_ca() {
    read -p "Introduce el país (EASYRSA_REQ_COUNTRY): " EASYRSA_REQ_COUNTRY
    read -p "Introduce la provincia (EASYRSA_REQ_PROVINCE): " EASYRSA_REQ_PROVINCE
    read -p "Introduce la ciudad (EASYRSA_REQ_CITY): " EASYRSA_REQ_CITY
    read -p "Introduce la organización (EASYRSA_REQ_ORG): " EASYRSA_REQ_ORG
    read -p "Introduce el correo electrónico (EASYRSA_REQ_EMAIL): " EASYRSA_REQ_EMAIL
    read -p "Introduce la unidad organizativa (EASYRSA_REQ_OU): " EASYRSA_REQ_OU
    read -p "Introduce 'ec' (EASYRSA_ALGO): " EASYRSA_ALGO
    read -p "Introduce el algoritmo de clave (sha512) (EASYRSA_DIGEST): " EASYRSA_DIGEST
}

# Solicitar datos de la CA si no se proporcionan como argumentos
if [ "$#" -eq 0 ]; then
    echo "No se proporcionaron argumentos. Solicitando datos de la CA..."
    solicitar_datos_ca
else
    # Asignar datos de la CA desde argumentos
    EASYRSA_REQ_COUNTRY=$1
    EASYRSA_REQ_PROVINCE=$2
    EASYRSA_REQ_CITY=$3
    EASYRSA_REQ_ORG=$4
    EASYRSA_REQ_EMAIL=$5
    EASYRSA_REQ_OU=$6
    EASYRSA_ALGO=$7
    EASYRSA_DIGEST=$8
fi

# Verificar si el directorio easy-rsa existe
if [ ! -d "ca/easy-rsa" ]; then
    mkdir -p ca/easy-rsa/
    ln -s /usr/share/easy-rsa/* ca/easy-rsa/
fi

# Cambiar al directorio easy-rsa
cd ca/easy-rsa

# Inicializar la infraestructura de clave pública
echo "Inicializando la infraestructura de clave pública..."
./easyrsa init-pki

# Crear el archivo vars
cat <<EOF > vars
set_var EASYRSA_REQ_COUNTRY    "$EASYRSA_REQ_COUNTRY"
set_var EASYRSA_REQ_PROVINCE   "$EASYRSA_REQ_PROVINCE"
set_var EASYRSA_REQ_CITY       "$EASYRSA_REQ_CITY"
set_var EASYRSA_REQ_ORG        "$EASYRSA_REQ_ORG"
set_var EASYRSA_REQ_EMAIL      "$EASYRSA_REQ_EMAIL"
set_var EASYRSA_REQ_OU         "$EASYRSA_REQ_OU"
set_var EASYRSA_ALGO           "$EASYRSA_ALGO"
set_var EASYRSA_DIGEST         "$EASYRSA_DIGEST"
EOF

# Construir la Autoridad de Certificación (CA)
echo "Construyendo la Autoridad de Certificación (CA)..."
./easyrsa build-ca

# Listar información del certificado de la CA
echo -e "\nInformación del Certificado de la Autoridad de Certificación (CA):"
openssl x509 -noout -modulus -in pki/ca.crt | openssl md5
openssl rsa -noout -modulus -in pki/private/ca.key | openssl md5

# Fin del script
echo "El script se ha ejecutado con éxito."
