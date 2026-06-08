#!/bin/bash
set -e

IS_PROD="${IS_PRODUCTION:-true}"

echo "Ambiente: $([ "$IS_PROD" = "true" ] && echo 'PRODUCCION' || echo 'SANDBOX')"

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

FLUTTER_VERSION="3.35.0"

if ! command -v flutter &> /dev/null; then
  git clone https://github.com/flutter/flutter.git --depth 1 --branch "$FLUTTER_VERSION" /opt/flutter
  export PATH="$PATH:/opt/flutter/bin"
  flutter precache --web
fi

flutter pub get
flutter build web --release
