let currentFuelLimit = 20;
let currentEngineLimit = 30;
let storedVehicleName = "Cargando...";

window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.action === "show") {
        let container = document.getElementById('onx-speedo');
        container.style.display = 'flex';
        
        if (data.size) container.style.transform = `scale(${data.size})`;
        if (data.bottom) container.style.bottom = `${data.bottom}px`;
        if (data.right) container.style.right = `${data.right}px`;

        if (data.fuelLimit) currentFuelLimit = data.fuelLimit;
        if (data.engineLimit) currentEngineLimit = data.engineLimit;

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
    
    else if (data.action === "hide") {
        document.getElementById('onx-speedo').style.display = 'none';
    } 
    
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

    else if (data.action === "cruise") {
        let cruiseIcon = document.getElementById('icon-cruise');
        if (data.status) {
            cruiseIcon.className = "mid-icon text-cruise-active"; 
        } else {
            cruiseIcon.className = "mid-icon text-off-neutral"; 
        }
    }
    
    else if (data.action === "update") {
        let speedEl = document.getElementById('speed');
        let speedStr = data.speed.toString().padStart(3, '0');
        speedEl.innerText = speedStr;
        
        if (data.speed > 0) {
            speedEl.classList.add('speed-active');
        } else {
            speedEl.classList.remove('speed-active');
        }

        document.getElementById('gear').innerText = data.gear;
        if (data.unit) {
            document.querySelector('.unit').innerText = data.unit;
        }

        let adjustedRpm = data.rpm;
        if (data.rpm > 0 && data.rpm <= 25) {
            adjustedRpm = 10; 
        }

        for (let i = 1; i <= 20; i++) {
            let block = document.getElementById('rpm-' + i);
            if (block) {
                if (adjustedRpm >= (i * 5)) {
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

        let lockIcon = document.getElementById('icon-lock');
        if (data.locked) {
            lockIcon.innerText = "🔒";
            lockIcon.className = "mid-icon text-off"; 
        } else {
            lockIcon.innerText = "🔓";
            lockIcon.className = "mid-icon text-on blink-active"; 
        }

        let lIcon = document.getElementById('icon-lights');
        if (data.lights === "high") {
            lIcon.className = "mid-icon text-highbeams"; 
        } else if (data.lights === "normal") {
            lIcon.className = "mid-icon text-on"; 
        } else {
            lIcon.className = "mid-icon text-off-neutral"; 
        }

        // Lógica reactiva de Radares Fijos
        let nameEl = document.getElementById('vehicle-name');
        if (data.radar) {
            nameEl.innerText = `RADAR: MAX ${data.radarSpeed}`;
            nameEl.className = "text-radar-alert blink-active"; 
        } else {
            nameEl.innerText = storedVehicleName;
            nameEl.className = ""; 
        }

        // Barra de Gasolina
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

        let fuelContainer = document.getElementById('fb-6')?.parentElement;
        if (fuelContainer) {
            if (data.fuel <= currentFuelLimit) {
                fuelContainer.classList.add('blink-active');
            } else {
                fuelContainer.classList.remove('blink-active');
            }
        }

        // Barra de Motor
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

        let engineContainer = document.getElementById('eb-6')?.parentElement;
        if (engineContainer) {
            if (data.engine <= currentEngineLimit) {
                engineContainer.classList.add('blink-active');
            } else {
                engineContainer.classList.remove('blink-active');
            }
        }
    }
});
