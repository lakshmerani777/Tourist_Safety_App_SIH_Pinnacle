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
            ${inc.mediaUrl ? `
            <div class="detail-row">
                <span class="detail-label">Attached Media</span>
                <div style="margin-top:8px; border-radius:8px; overflow:hidden; border:1px solid var(--border); background: var(--background);">
                    <img src="${inc.mediaUrl}" style="width:100%; height:auto; display:block;" alt="Incident Attachment" onerror="this.parentElement.innerHTML='<p style=\'padding:10px; color:var(--alert-red); font-size:12px;\'>Media failed to load</p>'">
                </div>
            </div>
            ` : ''}
            <div class="detail-row">
                <span class="detail-label">Reporter</span>
                ${inc.reportedBy && inc.reportedBy !== 'tourist' 
                    ? `<p style="color:var(--accent); cursor:pointer; text-decoration:underline;" onclick="viewTouristProfile('${inc.reportedBy}')">${inc.touristName}${inc.touristNationality ? ' (' + inc.touristNationality + ')' : ''}</p>`
                    : `<p style="color:var(--text-secondary)">${inc.touristName}${inc.touristNationality ? ' (' + inc.touristNationality + ')' : ''} (Unregistered)</p>`
                }
            </div>
            <div class="detail-row">
                <span class="detail-label">Reported By ID</span>
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

async function viewTouristProfile(userId) {
    document.getElementById('profile-modal').style.display = 'flex';
    document.getElementById('profile-loading').style.display = 'block';
    document.getElementById('profile-content').style.display = 'none';
    document.getElementById('profile-content').innerHTML = '';

    try {
        const response = await fetch(`/dashboard/api/tourists/${userId}/profile/`);
        const data = await response.json();
        
        document.getElementById('profile-loading').style.display = 'none';
        
        if (data.status === 'ok' && data.profile) {
            const p = data.profile;
            
            // Build the HTML content
            let html = `
                <div>
                    <div class="profile-section-title">Personal Identity</div>
                    <div class="profile-grid">
                        <div class="detail-row"><span class="detail-label">First Name</span><span>${p.firstName || '-'}</span></div>
                        <div class="detail-row"><span class="detail-label">Last Name</span><span>${p.lastName || '-'}</span></div>
                        <div class="detail-row"><span class="detail-label">Nationality</span><span>${p.nationality?.name || p.nationality || '-'}</span></div>
                        <div class="detail-row"><span class="detail-label">Passport No.</span><span>${p.passportNumber || '-'}</span></div>
                    </div>
                </div>
                
                <div>
                    <div class="profile-section-title">Contact Information</div>
                    <div class="profile-grid">
                        <div class="detail-row"><span class="detail-label">Phone</span><span>${p.phoneNumber ? '+' + (p.phoneCode || '') + ' ' + p.phoneNumber : '-'}</span></div>
                    </div>
                </div>

                <div>
                    <div class="profile-section-title">Travel Details</div>
                    <div class="profile-grid">
                        <div class="detail-row"><span class="detail-label">Purpose of Visit</span><span>${p.purposeOfVisit || '-'}</span></div>
                        <div class="detail-row"><span class="detail-label">Places to Visit</span><span>${p.placesToVisit || '-'}</span></div>
                    </div>
                </div>

                <div>
                    <div class="profile-section-title">Stay Details</div>
                    <div class="profile-grid">
                        <div class="detail-row"><span class="detail-label">Accommodation Type</span><span>${p.accommodationType || '-'}</span></div>
                        <div class="detail-row"><span class="detail-label">Property Name</span><span>${p.propertyName || '-'}</span></div>
                        <div class="detail-row" style="grid-column: span 2;"><span class="detail-label">Address</span><span>${p.fullAddress || '-'}</span></div>
                        <div class="detail-row"><span class="detail-label">Room / Unit</span><span>${p.roomNumber || '-'}</span></div>
                    </div>
                </div>

                <div>
                    <div class="profile-section-title">Emergency Contacts</div>
                    <div class="profile-grid">
                        <div class="detail-row"><span class="detail-label">Contact 1</span><span>${p.contact1Name || '-'}<br>${p.contact1Phone || '-'}</span></div>
                        <div class="detail-row"><span class="detail-label">Contact 2</span><span>${p.contact2Name || '-'}<br>${p.contact2Phone || '-'}</span></div>
                    </div>
                </div>

                <div>
                    <div class="profile-section-title">Medical Info</div>
                    <div class="profile-grid">
                        <div class="detail-row"><span class="detail-label">Blood Type</span><span>${p.bloodType || '-'}</span></div>
                        <div class="detail-row"><span class="detail-label">Insurance Policy</span><span>${p.insurancePolicyNumber || '-'}</span></div>
                        <div class="detail-row" style="grid-column: span 2;"><span class="detail-label">Allergies</span><span>${p.hasAllergies ? p.allergyDetails : 'None'}</span></div>
                        <div class="detail-row" style="grid-column: span 2;"><span class="detail-label">Conditions</span><span>${p.hasChronicConditions ? p.conditionDetails : 'None'}</span></div>
                        <div class="detail-row" style="grid-column: span 2;"><span class="detail-label">Medications</span><span>${p.takesRegularMedication ? p.medicationDetails : 'None'}</span></div>
                    </div>
                </div>
            `;
            
            document.getElementById('profile-content').innerHTML = html;
            document.getElementById('profile-content').style.display = 'grid';
        } else {
            document.getElementById('profile-content').innerHTML = '<p style="color:var(--alert-red)">Profile details could not be found.</p>';
            document.getElementById('profile-content').style.display = 'block';
        }
    } catch (e) {
        document.getElementById('profile-loading').style.display = 'none';
        document.getElementById('profile-content').innerHTML = '<p style="color:var(--alert-red)">Error loading profile.</p>';
        document.getElementById('profile-content').style.display = 'block';
    }
}

function closeProfileModal() {
    document.getElementById('profile-modal').style.display = 'none';
}
