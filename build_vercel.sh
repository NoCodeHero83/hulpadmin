#!/bin/bash
set -e

# IS_PRODUCTION controla el ambiente:
#   true  → producción  (default cuando no se define)
#   false → sandbox/staging
IS_PROD="${IS_PRODUCTION:-true}"

echo "▶ Ambiente: $([ "$IS_PROD" = "true" ] && echo 'PRODUCCIÓN' || echo 'SANDBOX')"

# Genera environment.json desde las variables de entorno de Vercel
cat > assets/environment_values/environment.json << EOF
{
  "privatekey": "${WOMPI_PRIVATE_KEY}",
  "publickey": "${WOMPI_PUBLIC_KEY}",
  "isProduction": ${IS_PROD},
  "supabaseUrl": "${SUPABASE_URL}",
  "supabaseAnonKey": "${SUPABASE_ANON_KEY}",
  "integrityKey": "${WOMPI_INTEGRITY_KEY}"
}
EOF

# Instala Flutter si no está disponible
if ! command -v flutter &> /dev/null; then
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 /opt/flutter
  export PATH="$PATH:/opt/flutter/bin"
  flutter precache --web
fi

flutter pub get
flutter build web --web-renderer html --release
