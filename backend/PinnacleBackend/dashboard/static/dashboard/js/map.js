/* ════════════════════════════════════════════════════════════════
   MAP VIEW — Leaflet.js + Polygon Geofencing
   ════════════════════════════════════════════════════════════════ */

// ─── State ───
let map;
let zonesLayer;
let drawingLayer;
let drawControl;
let drawnPolygon = null;
let isDrawingMode = false;

const severityColors = {
    HIGH: '#ef4444',
    MEDIUM: '#f59e0b',
    LOW: '#22c55e',
};

// ─── Initialize Map ───
document.addEventListener('DOMContentLoaded', () => {
    map = L.map('map', {
        center: [19.062641, 72.830899], // Mumbai
        zoom: 13,
        zoomControl: true,
    });

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; OpenStreetMap',
        maxZoom: 19,
    }).addTo(map);

    zonesLayer = L.featureGroup().addTo(map);
    drawingLayer = L.featureGroup().addTo(map);

    // Initialize Leaflet.Draw
    drawControl = new L.Control.Draw({
        draw: {
            polygon: {
                shapeOptions: {
                    color: '#ef4444',
                    weight: 3,
                    fillOpacity: 0.2,
                    fillColor: '#ef4444',
                },
                allowIntersection: false,
                showArea: true,
            },
            polyline: false,
            rectangle: false,
            circle: false,
            circlemarker: false,
            marker: false,
        },
        edit: {
            featureGroup: drawingLayer,
        },
    });

    // Handle polygon creation
    map.on(L.Draw.Event.CREATED, (e) => {
        drawingLayer.clearLayers();
        drawnPolygon = e.layer;
        drawingLayer.addLayer(drawnPolygon);

        // Show the points
        const latlngs = drawnPolygon.getLatLngs()[0];
        updatePointsDisplay(latlngs);

        // Open save modal
        document.getElementById('zone-modal').style.display = 'flex';
    });

    // Load zones
    renderZones(ZONES_DATA);
});

// ─── Zone Rendering ───

function renderZones(zones) {
    zonesLayer.clearLayers();
    const listEl = document.getElementById('zone-list');
    listEl.innerHTML = '';
    document.getElementById('zone-count').textContent = zones.length;

    zones.forEach(zone => {
        // Draw polygon on map
        if (zone.polygon && zone.polygon.length >= 3) {
            const latlngs = zone.polygon.map(p => [p.lat, p.lng]);
            const color = severityColors[zone.severity] || severityColors.HIGH;
            const opacity = zone.isActive !== false ? 0.25 : 0.08;

            const poly = L.polygon(latlngs, {
                color: color,
                weight: zone.isActive !== false ? 3 : 1,
                fillColor: color,
                fillOpacity: opacity,
                dashArray: zone.isActive !== false ? null : '5, 10',
            }).addTo(zonesLayer);

            poly.bindTooltip(zone.name, {
                permanent: false,
                direction: 'center',
                className: 'zone-tooltip',
            });
        }

        // Add to panel
        const card = document.createElement('div');
        card.className = 'zone-card';
        card.innerHTML = `
            <div class="zone-card-header">
                <span class="zone-card-name">${zone.name}</span>
                <span class="severity-badge severity-${(zone.severity || 'HIGH').toLowerCase()}">${zone.severity || 'HIGH'}</span>
            </div>
            <div class="zone-card-desc">${zone.description || 'No description'}</div>
            <div class="zone-card-actions">
                <button class="zone-btn-focus" onclick="focusZone(${JSON.stringify(zone.polygon).replace(/"/g, '&quot;')})">
                    <span class="material-icons-round">my_location</span>
                </button>
                <button class="zone-btn-edit" onclick="openEditZone('${zone.id}', '${(zone.name || '').replace(/'/g, "\\'")}', '${(zone.description || '').replace(/'/g, "\\'")}', '${zone.severity || 'HIGH'}')">
                    <span class="material-icons-round">edit</span>
                </button>
                <button class="zone-btn-toggle" onclick="toggleZone('${zone.id}', ${zone.isActive !== false})">
                    <span class="material-icons-round">${zone.isActive !== false ? 'visibility_off' : 'visibility'}</span>
                </button>
                <button class="zone-btn-delete" onclick="deleteZone('${zone.id}')">
                    <span class="material-icons-round">delete</span>
                </button>
            </div>
        `;
        listEl.appendChild(card);
    });
}

// ─── Drawing Controls ───

function startDrawing() {
    if (isDrawingMode) {
        map.removeControl(drawControl);
        isDrawingMode = false;
        document.getElementById('btn-draw-zone').innerHTML = '<span class="material-icons-round">draw</span> Draw New Zone';
    } else {
        map.addControl(drawControl);
        isDrawingMode = true;
        document.getElementById('btn-draw-zone').innerHTML = '<span class="material-icons-round">close</span> Cancel Drawing';
        // Programmatically start polygon drawing
        new L.Draw.Polygon(map, drawControl.options.draw.polygon).enable();
    }
}

function updatePointsDisplay(latlngs) {
    const el = document.getElementById('points-display');
    el.innerHTML = latlngs.map((ll, i) =>
        `<span style="color:var(--accent)">${i + 1}.</span> ${ll.lat.toFixed(5)}, ${ll.lng.toFixed(5)}`
    ).join('<br>');
}

// ─── Zone CRUD ───

async function saveZone() {
    const name = document.getElementById('zone-name').value.trim();
    const desc = document.getElementById('zone-desc').value.trim();
    const severity = document.getElementById('zone-severity').value;

    if (!name) { showToast('Zone name is required', 'error'); return; }
    if (!drawnPolygon) { showToast('Draw a polygon on the map first', 'error'); return; }

    const latlngs = drawnPolygon.getLatLngs()[0];
    const polygon = latlngs.map(ll => ({ lat: ll.lat, lng: ll.lng }));

    try {
        await apiPost('/dashboard/api/zones/create/', { name, description: desc, severity, polygon });
        showToast('Zone created successfully');
        closeZoneModal();
        refreshZones();
    } catch (e) {
        showToast('Error creating zone', 'error');
    }
}

async function toggleZone(id, currentlyActive) {
    try {
        await apiPost(`/dashboard/api/zones/${id}/update/`, { isActive: !currentlyActive });
        showToast(currentlyActive ? 'Zone deactivated' : 'Zone activated');
        refreshZones();
    } catch (e) {
        showToast('Error toggling zone', 'error');
    }
}

async function deleteZone(id) {
    if (!confirm('Are you sure you want to delete this zone?')) return;
    try {
        await apiPost(`/dashboard/api/zones/${id}/delete/`);
        showToast('Zone deleted');
        refreshZones();
    } catch (e) {
        showToast('Error deleting zone', 'error');
    }
}

function openEditZone(id, name, desc, severity) {
    document.getElementById('edit-zone-id').value = id;
    document.getElementById('edit-zone-name').value = name;
    document.getElementById('edit-zone-desc').value = desc;
    document.getElementById('edit-zone-severity').value = severity;
    document.getElementById('edit-zone-modal').style.display = 'flex';
}

async function updateZone() {
    const id = document.getElementById('edit-zone-id').value;
    const name = document.getElementById('edit-zone-name').value.trim();
    const desc = document.getElementById('edit-zone-desc').value.trim();
    const severity = document.getElementById('edit-zone-severity').value;

    try {
        await apiPost(`/dashboard/api/zones/${id}/update/`, { name, description: desc, severity });
        showToast('Zone updated');
        closeEditZoneModal();
        refreshZones();
    } catch (e) {
        showToast('Error updating zone', 'error');
    }
}

function focusZone(polygon) {
    if (polygon && polygon.length > 0) {
        const bounds = L.latLngBounds(polygon.map(p => [p.lat, p.lng]));
        map.fitBounds(bounds, { padding: [50, 50] });
    }
}

async function refreshZones() {
    try {
        const resp = await fetch('/dashboard/map/');
        const html = await resp.text();
        // Extract zones JSON from fetched page
        const match = html.match(/ZONES_DATA\s*=\s*(\[[\s\S]*?\]);/);
        if (match) {
            const zones = JSON.parse(match[1]);
            renderZones(zones);
        } else {
            location.reload();
        }
    } catch (e) {
        location.reload();
    }
}

// ─── Modal Controls ───

function closeZoneModal() {
    document.getElementById('zone-modal').style.display = 'none';
    document.getElementById('zone-name').value = '';
    document.getElementById('zone-desc').value = '';
    document.getElementById('zone-severity').value = 'HIGH';
    document.getElementById('points-display').innerHTML = 'Click on the map to add points';
    drawingLayer.clearLayers();
    drawnPolygon = null;
    if (isDrawingMode) {
        map.removeControl(drawControl);
        isDrawingMode = false;
        document.getElementById('btn-draw-zone').innerHTML = '<span class="material-icons-round">draw</span> Draw New Zone';
    }
}

function closeEditZoneModal() {
    document.getElementById('edit-zone-modal').style.display = 'none';
}
