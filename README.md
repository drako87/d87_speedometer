# 🏎️ D87 Speedometer

**D87 Speedometer** es un velocímetro flotante minimalista de alto rendimiento y calidad premium para servidores de GTA V Roleplay (FiveM). Su interfaz visual e interacciones dinámicas están fuertemente inspiradas en el ecosistema estético **Custom UI / AgencyOS** de servidores anglosajones de rol avanzado como **ONX RP**.

Desarrollado de manera nativa e independiente (*standalone*) con soporte multi-framework integrado, ofrece una optimización absoluta y un abanico de funciones avanzadas de telemetría vial que transformarán la conducción de tu servidor.

---

## 🌟 Características Principales

*   **Estética Flotante Premium:** Diseño limpio sin marcos opacos molestos, fuentes de alta legibilidad con sombreados suaves y caja de marchas en degradado azul eléctrico de alto impacto visual.
*   **Barra de Revoluciones (RPM) Semáforo:** Indicador de potencia horizontal dividido en 20 bloques sólidos y reactivos que cambian dinámicamente de color (Verde 🟢 -> Naranja 🟠 -> Rojo de Corte 🔴). Ajustado matemáticamente para marcar solo 2 bloques en ralentí.
*   **Barras de Estado Gemelas Verticales:** Lectura compacta en paralelo de los niveles de Combustible y Salud del motor con escalas de color de advertencia.
*   **Panel de Alertas Inteligentes (Blink System):** Las barras de estado y los iconos entran en modo de parpadeo crítico de forma independiente ante situaciones de emergencia (combustible en reserva, motor humeando críticamente o cinturón desabrochado).
*   **Detección Inteligente de Motocicletas:** Al subir a vehículos de dos ruedas (motos, quads o bicis), el indicador de cinturón desaparece por completo del HUD y se desactiva su comando para no romper el rol.
*   **Candado Invertido de Seguridad:** El icono del candado permanece en rojo sólido cuando el vehículo está cerrado y parpadea en verde cuando está abierto para advertir al jugador del riesgo de robo.

---

## 🛠️ Sistemas Avanzados Integrados

1.  **Control de Crucero Inteligente:** Permite fijar de manera nativa la velocidad actual del vehículo limitando la aceleración. Se desactiva automáticamente si el conductor pisa el freno de golpe ante una emergencia.
2.  **Faros Interactivos de Tres Estados:** El icono de la bombilla lee en tiempo real el filamento de luces del motor de GTA (Gris = Apagado, Verde = Posición/Cortas, Azul Eléctrico = Luces Largas de carretera).
3.  **Lector Geométrico de Radares Fijos:** Escáner perimetral de coordenadas que intercepta la posición del vehículo. Al aproximarse a un radar, el nombre del coche muta dinámicamente en una alerta roja parpadeante indicando la velocidad máxima permitida (Ej: `⚠️ RADAR: MAX 50`).

---

## ⚡ Ventajas Técnicas

*   **Soporte Multiframework Plug & Play:** Detecta automáticamente si tu servidor ejecuta **Qbox, QBCore o ESX**, adaptando las nativas de cierre centralizado y seguridad sin modificar una sola línea de código.
*   **Compatibilidad Absoluta de Gasolineras:** Lector modular inteligente con soporte nativo e integrado para `bazufix-fuel`, `ox_fuel`, `LegacyFuel`, `qb-fuel` y el sistema de carburante por defecto de GTA.
*   **Consumo de Recursos Ultra-Bajo:** Hilo de renderizado altamente optimizado apoyado sobre las estructuras estables de FiveM. El recurso se mantiene en torno a **0.01 ms - 0.02 ms** en pleno funcionamiento.
*   **Carga Local Segura (MIME Type Fix):** No consume CDNs ni dependencias web externas (como Cloudflare o FontAwesome), lo que garantiza que cargue al 100% de tus jugadores de forma instantánea sin sufrir bloqueos estrictos de los navegadores internos.

---

## ⚙️ Archivo de Configuración (`config.lua`)

El script cuenta con un panel de opciones completo para que personalices el HUD a la medida exacta de tu comunidad sin necesidad de tocar código web:

```lua
Config = {}

-- CONFIGURACIÓN DE POSICIÓN Y TAMAÑO VISUAL
Config.Size = 1.0          -- Escala general del HUD (0.8 = Más chico, 1.2 = Más grande)
Config.BottomMargin = 40   -- Distancia desde el borde inferior de la pantalla (Píxeles)
Config.RightMargin = 40    -- Distancia desde el borde derecho de la pantalla (Píxeles)

-- CONFIGURACIÓN DE ELEMENTOS (true = Activado / false = Desactivado)
Config.ShowVehicleName = true 
Config.ShowRpmBar = true      
Config.ShowFuelBar = true     
Config.ShowEngineBar = true   
Config.ShowGearBox = true     

-- AJUSTES MECÁNICOS Y ALERTAS
Config.UseMPH = false             -- true = Millas por Hora / false = KM/H
Config.SeatbeltKey = 'B'          -- Tecla nativa para el Cinturón de Seguridad
Config.CruiseKey = 'Y'            -- Tecla nativa para el Control de Crucero
Config.FuelAlertPercent = 20      -- Porcentaje para activar la reserva de gasolina
Config.EngineAlertPercent = 30    -- Porcentaje para activar la alerta crítica de motor

-- BASE DE DATOS DE RADARES FIJOS (Añade infinitos mediante vec3)
Config.RadarDistance = 80.0       -- Distancia en metros para activar la alerta del HUD
Config.Radars = {
    { coords = vec3(220.0, -815.0, 30.0), maxSpeed = 50 },  
    { coords = vec3(-250.0, -900.0, 30.0), maxSpeed = 80 }, 
}
```

---

## 📥 Instalación

1.  Descarga el recurso y renombra la carpeta principal como `D87_Speedometer`.
2.  Mueve la carpeta al directorio de recursos de tu servidor (ej: `[resources] / D87_Speedometer`).
3.  Abre el archivo de configuración `server.cfg` de tu servidor de FiveM.
4.  Asegúrate de inicializar el velocímetro **debajo** de las dependencias de tus scripts de frameworks, gasolineras o llaves agregando la siguiente línea:
    ```cfg
    ensure D87_Speedometer
    ```
5.  Guarda los cambios, inicia tu servidor y ¡disfruta de la mejor experiencia de conducción!

---

## 👤 Créditos y Autoría

*   **Script:** D87 Speedometer
*   **Autor Oficial:** `Drako87/Dracatt`
*   **Framework de Desarrollo:** Qbox, QBCore, ESX Legacy & Standalone Project.
