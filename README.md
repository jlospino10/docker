# Docker Launcher

Repositorio independiente con un stack Docker para desarrollo que incluye:
- PHP 8.2 + Apache
- Node 20 + Puppeteer
- MySQL 8

Instrucciones rápidas:

1. Copiar .env.example a .env y ajustar credenciales si se desea
2. Construir y levantar:
   docker compose up --build -d
3. Entrar al contenedor PHP:
   docker compose exec app bash
4. Probar Puppeteer:
   npm run test-puppeteer

Puerto HTTP: http://localhost:8080 (mapea al puerto 80 del contenedor)
MySQL: puerto en host 3307 -> container 3306

Co-authored-by: Copilot App <223556219+Copilot@users.noreply.github.com>
