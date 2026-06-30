let currentFuelLimit = 20;
let currentEngineLimit = 30;
let storedVehicleName = "Cargando...";

window.addEventListener('message', function(event) {
    let data = event.data;

    // 1. ACCIÓN: MOSTRAR INTERFAZ E INICIALIZAR CONFIGURACIÓN DEL SERVIDOR
    if (data.action === "show") {
        let container = document.getElementById('onx-speedo');
        container.style.display = 'flex';
        
        if (data.size) container.style.transform = `scale(${data.size})`;
        if (data.bottom) container.style.bottom = `${data.bottom}px`;
        if (data.right) container.style.right = `${data.right}px`;

        // CORREGIDO: Ahora sí guardamos correctamente las alertas dinámicas del config.lua
        if (data.fuelLimit !== undefined) currentFuelLimit = data.fuelLimit;
        if (data.engineLimit !== undefined) currentEngineLimit = data.engineLimit;

        // Visibilidad dinámica de elementos según el Config
        document.getElementById('vehicle-container').style.display = data.showName ? 'flex' : 'none';
        document.querySelector('.rpm-heavy-bar').style.display = data.showRpm ? 'flex' : 'none';
        document.querySelector('.status-vertical:nth-child(2)').style.display = data.showFuel ? 'flex' : 'none';
        document.querySelector('.status-vertical:nth-child(1)').style.display = data.showEngine ? 'flex' : 'none';
        document.querySelector('.gear-container').style.display = data.showGear ? 'flex' : 'none';

        if (data.vehicleName) {
            storedVehicleName = data.vehicleName;
            document.getElementById('vehicle-name').innerText = storedVehicleName;
        }

        let sbIcon = document.getElementById('icon-seatbelt');
        if (data.hideSeatbelt) {
            sbIcon.style.display = 'none'; 
        } else {
            sbIcon.style.display = 'inline-block'; 
        }
    } 
    
    // 2. ACCIÓN: OCULTAR HUD
    else if (data.action === "hide") {
        document.getElementById('onx-speedo').style.display = 'none';
    } 
    
    // 3. ACCIÓN: ESTADO DEL CINTURÓN DE SEGURIDAD
    else if (data.action === "seatbelt") {
        let sbIcon = document.getElementById('icon-seatbelt');
        if (data.status) {
            sbIcon.innerText = "⧮"; 
            sbIcon.className = "mid-icon text-on"; 
        } else {
            sbIcon.innerText = "⧯"; 
            sbIcon.className = "mid-icon text-off blink-active"; 
        }
    } 

    // 4. ACCIÓN: ESTADO DEL CONTROL DE CRUCERO
    else if (data.action === "cruise") {
        let cruiseIcon = document.getElementById('icon-cruise');
        if (data.status) {
            cruiseIcon.className = "mid-icon text-cruise-active"; 
        } else {
            cruiseIcon.className = "mid-icon text-off-neutral"; 
        }
    }
    
    // 5. ACCIÓN: ACTUALIZACIÓN EN TIEMPO REAL (TELEMETRÍA)
    else if (data.action === "update") {
        // Marcador numérico de velocidad
        let speedEl = document.getElementById('speed');
        let speedStr = data.speed.toString().padStart(3, '0');
        speedEl.innerText = speedStr;
        
        if (data.speed > 0) {
            speedEl.classList.add('speed-active');
        } else {
            speedEl.classList.remove('speed-active');
        }

        // 🛠️ CORREGIDO: Adaptación dinámica del vehículo frame a frame en el Update
        let sbIcon = document.getElementById('icon-seatbelt');
        if (data.vehType === "plane" || data.vehType === "heli" || data.vehType === "boat" || data.vehType === "bike") {
            if (data.vehType !== "bike") {
                document.querySelector('.gear-container').style.opacity = '0'; // Oculta marchas en aeronaves/barcos
            } else {
                document.querySelector('.gear-container').style.opacity = '1'; // Las motos sí llevan marchas
            }
            sbIcon.style.display = 'none'; // Oculta cinturón en motos, barcos y aviones por completo
        } else {
            document.querySelector('.gear-container').style.opacity = '1';
            sbIcon.style.display = 'inline-block'; // Se muestra solo en coches convencionales
        }

        // Actualizar el valor del Odómetro con ceros a la izquierda
        if (data.odo !== undefined) {
            document.getElementById('odo-value').innerText = data.odo.toString().padStart(6, '0');
        }
        if (data.unit) {
            document.querySelector('.unit').innerText = data.unit;
            document.querySelector('.odo-unit').innerText = data.unit.split('/')[0]; // Extrae KM o MI
        }

        document.getElementById('gear').innerText = data.gear;

        // Lógica de Renderizado de la barra de RPM
        let adjustedRpm = data.rpm;
        if (data.rpm > 0 && data.rpm <= 25) {
            adjustedRpm = 10; 
        } else if (data.rpm === 0) {
            adjustedRpm = 0;
        }

        for (let i = 1; i <= 20; i++) {
            let block = document.getElementById('rpm-' + i);
            if (block) {
                if (adjustedRpm > 0 && adjustedRpm >= (i * 5)) {
                    if (i <= 10) {
                        block.className = "rpm-block rpm-low";
                    } else if (i <= 16) {
                        block.className = "rpm-block rpm-medium";
                    } else {
                        block.className = "rpm-block rpm-high";
                    }
                } else {
                    block.className = "rpm-block"; 
                }
            }
        }

        // Estado del Cierre Centralizado (Puertas)
        let lockIcon = document.getElementById('icon-lock');
        if (data.locked) {
            lockIcon.innerText = "🔒";
            lockIcon.className = "mid-icon text-off"; 
        } else {
            lockIcon.innerText = "🔓";
            lockIcon.className = "mid-icon text-on blink-active"; 
        }

        // Estado de las Luces
        let lIcon = document.getElementById('icon-lights');
        if (data.lights === "high") {
            lIcon.className = "mid-icon text-highbeams"; 
        } else if (data.lights === "normal") {
            lIcon.className = "mid-icon text-on"; 
        } else {
            lIcon.className = "mid-icon text-off-neutral"; 
        }

        // Alerta Visual de Radares Fijos en el Nombre del Vehículo
        let nameEl = document.getElementById('vehicle-name');
        if (data.radar) {
            nameEl.innerText = `RADAR: MAX ${data.radarSpeed}`;
            nameEl.className = "text-radar-alert blink-active"; 
        } else {
            nameEl.innerText = storedVehicleName;
            nameEl.className = ""; 
        }

        // Renderizado Dinámico de la Barra de Combustible (6 bloques)
        for (let i = 1; i <= 6; i++) {
            let bar = document.getElementById('fb-' + i);
            if (bar) {
                if (data.fuel >= (i * 16.6) - 5) {
                    bar.classList.add('f-bar-active');
                } else {
                    bar.classList.remove('f-bar-active');
                }
            }
        }

        // Parpadeo de alerta por combustible bajo (Reserva)
        let fuelContainer = document.getElementById('fb-6')?.parentElement;
        if (fuelContainer) {
            if (data.fuel <= currentFuelLimit) {
                fuelContainer.classList.add('blink-active');
            } else {
                fuelContainer.classList.remove('blink-active');
            }
        }

        // Renderizado por Colores de la Barra del Motor (6 bloques)
        for (let i = 1; i <= 6; i++) {
            let bar = document.getElementById('eb-' + i);
            if (bar) {
                bar.className = "eng-bar"; 
                if (data.engine >= (i * 16.6) - 5) {
                    if (data.engine > 60) {
                        bar.classList.add('eng-bar-active-green');
                    } else if (data.engine > 30) {
                        bar.classList.add('eng-bar-active-yellow');
                    } else {
                        bar.classList.add('eng-bar-active-red');
                    }
                }
            }
        }

        // Parpadeo de alerta por motor muy dañado
        let engineContainer = document.getElementById('eb-6')?.parentElement;
        if (engineContainer) {
            if (data.engine <= currentEngineLimit) {
                engineContainer.classList.add('blink-active');
            } else {
                engineContainer.classList.remove('blink-active');
            }
        }
    }


        // Marchas y Unidades (KM/H o MPH)
        document.getElementById('gear').innerText = data.gear;
        if (data.unit) {
            document.querySelector('.unit').innerText = data.unit;
        }

        // Lógica de Renderizado de la barra de RPM
        let adjustedRpm = data.rpm;
        // CORREGIDO: Si el coche está parado o el motor apagado, forzamos apagado total de bloques
        if (data.rpm > 0 && data.rpm <= 25) {
            adjustedRpm = 10; 
        } else if (data.rpm === 0) {
            adjustedRpm = 0;
        }

        for (let i = 1; i <= 20; i++) {
            let block = document.getElementById('rpm-' + i);
            if (block) {
                if (adjustedRpm > 0 && adjustedRpm >= (i * 5)) {
                    if (i <= 10) {
                        block.className = "rpm-block rpm-low";
                    } else if (i <= 16) {
                        block.className = "rpm-block rpm-medium";
                    } else {
                        block.className = "rpm-block rpm-high";
                    }
                } else {
                    block.className = "rpm-block"; 
                }
            }
        }

        // Estado del Cierre Centralizado (Puertas)
        let lockIcon = document.getElementById('icon-lock');
        if (data.locked) {
            lockIcon.innerText = "🔒";
            lockIcon.className = "mid-icon text-off"; 
        } else {
            lockIcon.innerText = "🔓";
            lockIcon.className = "mid-icon text-on blink-active"; 
        }

        // Estado de las Luces
        let lIcon = document.getElementById('icon-lights');
        if (data.lights === "high") {
            lIcon.className = "mid-icon text-highbeams"; 
        } else if (data.lights === "normal") {
            lIcon.className = "mid-icon text-on"; 
        } else {
            lIcon.className = "mid-icon text-off-neutral"; 
        }

        // Alerta Visual de Radares Fijos en el Nombre del Vehículo
        let nameEl = document.getElementById('vehicle-name');
        if (data.radar) {
            nameEl.innerText = `RADAR: MAX ${data.radarSpeed}`;
            nameEl.className = "text-radar-alert blink-active"; 
        } else {
            nameEl.innerText = storedVehicleName;
            nameEl.className = ""; 
        }

        // Renderizado Dinámico de la Barra de Combustible (6 bloques)
        for (let i = 1; i <= 6; i++) {
            let bar = document.getElementById('fb-' + i);
            if (bar) {
                if (data.fuel >= (i * 16.6) - 5) {
                    bar.classList.add('f-bar-active');
                } else {
                    bar.classList.remove('f-bar-active');
                }
            }
        }

        // Parpadeo de alerta por combustible bajo (Reserva)
        let fuelContainer = document.getElementById('fb-6')?.parentElement;
        if (fuelContainer) {
            if (data.fuel <= currentFuelLimit) {
                fuelContainer.classList.add('blink-active');
            } else {
                fuelContainer.classList.remove('blink-active');
            }
        }

        // Renderizado por Colores de la Barra del Motor (6 bloques)
        for (let i = 1; i <= 6; i++) {
            let bar = document.getElementById('eb-' + i);
            if (bar) {
                bar.className = "eng-bar"; // Reseteamos clases de color
                if (data.engine >= (i * 16.6) - 5) {
                    if (data.engine > 60) {
                        bar.classList.add('eng-bar-active-green');
                    } else if (data.engine > 30) {
                        bar.classList.add('eng-bar-active-yellow');
                    } else {
                        bar.classList.add('eng-bar-active-red');
                    }
                }
            }
        }

        // Parpadeo de alerta por motor muy dañado
        let engineContainer = document.getElementById('eb-6')?.parentElement;
        if (engineContainer) {
            if (data.engine <= currentEngineLimit) {
                engineContainer.classList.add('blink-active');
            } else {
                engineContainer.classList.remove('blink-active');
            }
        }
    }
);
