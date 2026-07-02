let currentFuelLimit = 20;
let currentEngineLimit = 30;
let storedVehicleName = "Cargando...";

window.addEventListener('message', function (event) {
    let data = event.data;

    // 1. ACCIÓN: MOSTRAR INTERFAZ E INICIALIZAR CONFIGURACIÓN DEL SERVIDOR
    if (data.action === "show") {
        let container = document.getElementById('d87-speedo');
        container.style.display = 'flex';

        if (data.size) container.style.transform = `scale(${data.size})`;
        if (data.bottom) container.style.bottom = `${data.bottom}px`;
        if (data.right) container.style.right = `${data.right}px`;

        if (data.fuelLimit !== undefined) currentFuelLimit = data.fuelLimit;
        if (data.engineLimit !== undefined) currentEngineLimit = data.engineLimit;

        // Visibilidad dinámica de elementos según el Config (ids explícitos en vez de nth-child,
        // para que no dependa del orden exacto de los divs en el HTML)
        document.getElementById('vehicle-container').style.display = data.showName ? 'flex' : 'none';
        document.querySelector('.rpm-heavy-bar').style.display = data.showRpm ? 'flex' : 'none';
        document.getElementById('fuel-status-block').style.display = data.showFuel ? 'flex' : 'none';
        document.getElementById('engine-status-block').style.display = data.showEngine ? 'flex' : 'none';
        document.querySelector('.gear-container').style.display = data.showGear ? 'flex' : 'none';

        if (data.vehicleName) {
            storedVehicleName = data.vehicleName;
            document.getElementById('vehicle-name').innerText = storedVehicleName;
        }

        let sbIcon = document.getElementById('icon-seatbelt');
        sbIcon.style.display = data.hideSeatbelt ? 'none' : 'inline-block';
    }

    // 2. ACCIÓN: OCULTAR HUD
    else if (data.action === "hide") {
        document.getElementById('d87-speedo').style.display = 'none';
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
        cruiseIcon.className = data.status ? "mid-icon text-cruise-active" : "mid-icon text-off-neutral";
    }

    // 5. ACCIÓN: ACTUALIZACIÓN EN TIEMPO REAL (TELEMETRÍA)
    else if (data.action === "update") {
        // Marcador numérico de velocidad
        let speedEl = document.getElementById('speed');
        speedEl.innerText = data.speed.toString().padStart(3, '0');
        speedEl.classList.toggle('speed-active', data.speed > 0);

        // Adaptación dinámica del vehículo frame a frame
        let sbIcon = document.getElementById('icon-seatbelt');
        if (data.vehType === "plane" || data.vehType === "heli" || data.vehType === "boat" || data.vehType === "bike") {
            document.querySelector('.gear-container').style.opacity = (data.vehType === "bike") ? '1' : '0';
            sbIcon.style.display = 'none'; // Sin cinturón en motos, barcos y aviones
        } else {
            document.querySelector('.gear-container').style.opacity = '1';
            sbIcon.style.display = 'inline-block';
        }

        // Odómetro
        if (data.odo !== undefined) {
            document.getElementById('odo-value').innerText = data.odo.toString().padStart(6, '0');
        }
        if (data.unit) {
            document.querySelector('.unit').innerText = data.unit;
            document.querySelector('.odo-unit').innerText = data.unit.split('/')[0]; // KM o MI
        }

        document.getElementById('gear').innerText = data.gear;

        // Barra de RPM
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
                    block.className = (i <= 10) ? "rpm-block rpm-low" : (i <= 16) ? "rpm-block rpm-medium" : "rpm-block rpm-high";
                } else {
                    block.className = "rpm-block";
                }
            }
        }

        // Cierre centralizado (puertas)
        let lockIcon = document.getElementById('icon-lock');
        if (data.locked) {
            lockIcon.innerText = "🔒";
            lockIcon.className = "mid-icon text-off";
        } else {
            lockIcon.innerText = "🔓";
            lockIcon.className = "mid-icon text-on blink-active";
        }

        // Luces
        let lIcon = document.getElementById('icon-lights');
        if (data.lights === "high") {
            lIcon.className = "mid-icon text-highbeams";
        } else if (data.lights === "normal") {
            lIcon.className = "mid-icon text-on";
        } else {
            lIcon.className = "mid-icon text-off-neutral";
        }

        // Alerta de radar fijo sobre el nombre del vehículo
        let nameEl = document.getElementById('vehicle-name');
        if (data.radar) {
            nameEl.innerText = `RADAR: MAX ${data.radarSpeed}`;
            nameEl.className = "text-radar-alert blink-active";
        } else {
            nameEl.innerText = storedVehicleName;
            nameEl.className = "";
        }

        // Barra de combustible (6 bloques)
        for (let i = 1; i <= 6; i++) {
            let bar = document.getElementById('fb-' + i);
            if (bar) {
                bar.classList.toggle('f-bar-active', data.fuel >= (i * 16.6) - 5);
            }
        }

        // Parpadeo por combustible bajo (reserva)
        let fuelContainer = document.getElementById('fb-6')?.parentElement;
        if (fuelContainer) {
            fuelContainer.classList.toggle('blink-active', data.fuel <= currentFuelLimit);
        }

        // Barra del motor por colores (6 bloques)
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

        // Parpadeo por motor muy dañado
        let engineContainer = document.getElementById('eb-6')?.parentElement;
        if (engineContainer) {
            engineContainer.classList.toggle('blink-active', data.engine <= currentEngineLimit);
        }
    }
});
