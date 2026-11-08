# JuinLoks · guía de instalación

JuinLoks es una app web que se instala en el iPhone, el iPad y el Mac. Se sincroniza entre todos tus dispositivos y funciona aunque no tengas conexión.

Necesitas dos cuentas gratuitas:
- **Supabase**: guarda tus datos.
- **GitHub**: publica la app en internet.

Todo se hace desde el navegador y lleva unos 15 minutos.

---

## Paso 1 · Crear la base de datos (Supabase)

1. Entra en **supabase.com** y pulsa **Start your project**. Puedes registrarte con tu cuenta de GitHub.
2. Pulsa **New project**:
   - **Name:** `juinloks`
   - **Database Password:** inventa una y guárdala. JuinLoks no la necesita.
   - **Region:** la más cercana a ti.
   - Pulsa **Create new project** y espera 1 o 2 minutos.
3. En el menú de la izquierda, abre **SQL Editor** y pulsa **New query**.
4. Abre el archivo `supabase.sql` de esta carpeta con TextEdit o Notas. Copia todo su contenido, pégalo en el editor y pulsa **Run**. Debe aparecer *Success*.
5. Abre **Authentication → Sign In / Providers → Email** y **desactiva "Confirm email"**. Así tu cuenta funciona al momento, sin tener que confirmar el correo. Guarda el cambio.
6. Abre **Project Settings → API** (en algunos proyectos se llama **Data API / API Keys**) y copia dos datos:
   - **Project URL**, por ejemplo `https://abcdefghijk.supabase.co`
   - La clave **anon public** (o **publishable**)

## Paso 2 · Publicar la app (GitHub Pages)

1. Entra en **github.com** y crea una cuenta si no la tienes.
2. Arriba a la derecha, pulsa **+ → New repository**:
   - **Repository name:** `juinloks`
   - Marca **Public**.
   - Pulsa **Create repository**.
3. En la página del repositorio, pulsa **uploading an existing file**.
4. Abre la carpeta `JuinLoks-app` en el Finder y arrastra todo su contenido a la página, carpetas `icons` y `vendor` incluidas. Pulsa **Commit changes**.
5. En el repositorio, abre `config.js` y pulsa el **lápiz** para editarlo. Sustituye `TU_URL_DE_SUPABASE` y `TU_CLAVE_PUBLICA` por los dos datos del paso 1.6. Deja las comillas y pulsa **Commit changes**.
6. Abre **Settings → Pages**. En **Source** elige **Deploy from a branch**, y en **Branch** elige `main` y `/ (root)`. Pulsa **Save**.
7. Espera 1 o 2 minutos y recarga la página. Arriba aparece tu dirección, por ejemplo `https://tu-usuario.github.io/juinloks/`.

## Paso 3 · Crear tu cuenta en JuinLoks

1. Abre tu dirección, escribe tu correo y una contraseña, y pulsa **Crear cuenta**.
2. **Recomendado:** vuelve a Supabase y, en **Authentication → Sign In / Providers**, desactiva **"Allow new users to sign up"**. Así nadie más puede crear cuentas en tu proyecto. Tus datos ya son privados en cualquier caso: cada usuario solo puede leer los suyos.

## Paso 4 · Instalarla en tus dispositivos

- **iPhone / iPad:**
  1. Abre tu dirección en **Safari**.
  2. Pulsa **Compartir → Añadir a pantalla de inicio → Añadir**.
  3. Ábrela desde el icono y entra con tu correo y contraseña.
- **Mac (Safari):** **Archivo → Añadir al Dock**.
- **Mac (Chrome):** menú **⋮ → Transmitir, guardar y compartir → Instalar página como aplicación**.

Inicia sesión en cada dispositivo con la misma cuenta. Lo que anotes en uno aparecerá en los demás.

## Traer tus datos de la versión anterior

1. Abre el antiguo `JuinLoks.html` y ve a **Ajustes → Copia de seguridad → Descargar copia**.
2. En la nueva app, ve a **Ajustes → Copia de seguridad → Importar copia**, elige ese archivo y confirma.

---

## Preguntas frecuentes

**¿Qué pasa si no tengo internet?**
Puedes seguir usándola con normalidad. Arriba verás «Sin conexión». Cuando vuelva la conexión, los cambios se suben solos.

**¿Es seguro que el repositorio sea público?**
Sí. Lo público es el código de la app, no tus datos. La clave de `config.js` está pensada para estar a la vista: sin tu contraseña no permite leer nada.

**La app dice «Error al sincronizar».**
En Supabase, los proyectos gratuitos se pausan tras una semana sin uso. Entra en supabase.com y pulsa **Restore project**. Mientras tanto, tus datos están a salvo en tus dispositivos.

**¿Cómo actualizo la app si me haces cambios?**
Sube a GitHub el nuevo `index.html` y sustituye el anterior. **No reemplaces `config.js`.** Los dispositivos cargan la versión nueva la segunda vez que abres la app.

---

## Calendario de Apple (suscripción automática)

Para que tus tareas y hábitos con hora aparezcan solos en el Calendario de Apple:

1. En Supabase, abre **SQL Editor → New query**, pega el contenido de `calendario.sql` y pulsa **Run**. Solo una vez.
2. En JuinLoks, ve a **Tareas → Calendario de Apple → Crear enlace de suscripción** y pulsa **Suscribirme en Calendario de Apple**.

El calendario «JuinLoks» se actualiza solo. Funciona en un sentido: los cambios se hacen en JuinLoks.
