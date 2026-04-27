#!/bin/bash
set -e

# Genera environment.json desde las variables de entorno de Vercel
cat > assets/environment_values/environment.json << EOF
{
  "privatekey": "${WOMPI_PRIVATE_KEY}",
  "publickey": "${WOMPI_PUBLIC_KEY}",
  "isProduction": true,
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
