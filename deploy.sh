#!/usr/bin/env bash
set -e

echo "=== 1. Build Flutter web ==="
cd flutter
flutter build web --release
cd ..

echo ""
echo "=== 2. Prepare public/ ==="
rm -rf public
mkdir -p public
cp -r flutter/build/web/* public/
cp -r backend/static/* public/static/

echo ""
echo "=== 3. Deploy to Vercel ==="
echo ""
echo "First time:"
echo "  npx vercel --prod"
echo ""
echo "Subsequent:"
echo "  vercel --prod"
echo ""
echo "Set environment variables in Vercel dashboard:"
echo "  OLLAMA_HOST    → skip (no disponible en Vercel)"
echo "  HF_TOKEN       → opcional (HuggingFace fallback)"
echo "  SECRET_KEY     → generar clave aleatoria segura"
echo "  DATABASE_URL   → opcional (usar Vercel Postgres o Neon)"
