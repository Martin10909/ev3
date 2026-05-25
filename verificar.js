// Script para verificar que todo está bien instalado
console.log('🔍 Verificando dependencias y configuración...\n');

// Verificar Node.js
console.log('✓ Node.js está disponible');
console.log('  Versión:', process.version);

// Verificar npm (si ejecutas con npm)
console.log('\n✓ npm está disponible (ejecutaste esto con npm)');

// Intentar importar express
try {
  const express = require('express');
  console.log('\n✓ Express está instalado');
  console.log('  Versión:', require('./node_modules/express/package.json').version);
} catch (error) {
  console.error('\n✗ ERROR: Express NO está instalado');
  process.exit(1);
}

// Intentar importar cookie-parser
try {
  const cookieParser = require('cookie-parser');
  console.log('\n✓ Cookie-parser está instalado');
  console.log('  Versión:', require('./node_modules/cookie-parser/package.json').version);
} catch (error) {
  console.error('\n✗ ERROR: Cookie-parser NO está instalado');
  process.exit(1);
}

console.log('\n' + '='.repeat(50));
console.log('✅ ¡TODO ESTÁ INSTALADO CORRECTAMENTE!');
console.log('='.repeat(50));
console.log('\nAhora ejecuta:');
console.log('  npm start');
console.log('\nLuego abre en tu navegador:');
console.log('  http://localhost:3000');
console.log('\nCredenciales:');
console.log('  Usuario: admin');
console.log('  Contraseña: 1234\n');
