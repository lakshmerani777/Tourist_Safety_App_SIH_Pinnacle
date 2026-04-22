/* ════════════════════════════════════════════════════════════════
   INCIDENTS — AJAX Interactions & Filtering
   ════════════════════════════════════════════════════════════════ */

document.addEventListener('DOMContentLoaded', () => {
    updateStats();
});

function updateStats() {
    const rows = document.querySelectorAll('#incidents-tbody tr[data-id]');
    let pending = 0, reviewed = 0, resolved = 0;
    rows.forEach(r => {
        const s = r.dataset.status;
        if (s === 'pending') pending++;
        else if (s === 'reviewed') reviewed++;
        else if (s === 'resolved') resolved++;
    });
    document.getElementById('stat-pending').textContent = pending;
    document.getElementById('stat-reviewed').textContent = reviewed;
    document.getElementById('stat-resolved').textContent = resolved;
    document.getElementById('stat-total-inc').textContent = rows.length;
}

function filterIncidents(status, btn) {
    // Update active button
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');

    const rows = document.querySelectorAll('#incidents-tbody tr[data-id]');
    rows.forEach(row => {
        if (status === 'all' || row.dataset.status === status) {
            row.style.display = '';
        } else {
            row.style.display = 'none';
        }
    });
}

async function updateStatus(id, newStatus) {
    try {
        const res = await apiPost(`/dashboard/api/incidents/${id}/status/`, { status: newStatus });
        if (res.status === 'ok') {
            showToast(`Incident marked as ${newStatus}`);
            setTimeout(() => location.reload(), 500);
        } else {
            showToast(res.error || 'Failed to update status', 'error');
        }
    } catch (e) {
        showToast('Network error', 'error');
    }
}

function viewIncident(id) {
    const inc = INCIDENTS_DATA.find(i => i.id === id);
    if (!inc) return;

    const body = document.getElementById('incident-detail-body');
    body.innerHTML = `
        <div style="display:grid;gap:16px">
            <div class="detail-row">
                <span class="detail-label">Type</span>
                <span class="type-badge">${inc.type}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Status</span>
                <span class="status-pill status-${inc.status}">${inc.status.charAt(0).toUpperCase() + inc.status.slice(1)}</span>
            </div>
            <div class="detail-row">
                <span class="detail-label">Description</span>
                <p style="color:var(--text-secondary);line-height:1.6">${inc.description}</p>
            </div>
            <div class="detail-row">
                <span class="detail-label">Location</span>
                <p style="color:var(--text-secondary)">${inc.address}</p>
            </div>
            <div class="detail-row">
                <span class="detail-label">Coordinates</span>
                <p style="color:var(--text-muted);font-size:12px">${inc.latitude}, ${inc.longitude}</p>
            </div>
            <div class="detail-row">
                <span class="detail-label">Reporter</span>
                <p style="color:var(--text-secondary)">${inc.touristName}${inc.touristNationality ? ' (' + inc.touristNationality + ')' : ''}</p>
            </div>
            <div class="detail-row">
                <span class="detail-label">Reported By</span>
                <p style="color:var(--text-muted)">${inc.reportedBy}</p>
            </div>
            <div class="detail-row">
                <span class="detail-label">Reported At</span>
                <p style="color:var(--text-muted);font-size:12px">${inc.reportedAt}</p>
            </div>
        </div>
        <style>
            .detail-row { display: flex; flex-direction: column; gap: 4px; }
            .detail-label { font-size: 11px; font-weight: 700; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.5px; }
        </style>
    `;
    document.getElementById('incident-modal').style.display = 'flex';
}

function closeIncidentModal() {
    document.getElementById('incident-modal').style.display = 'none';
}
