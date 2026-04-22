/* ════════════════════════════════════════════════════════════════
   ALERTS — AJAX Interactions
   ════════════════════════════════════════════════════════════════ */

function openAlertModal() {
    document.getElementById('alert-modal').style.display = 'flex';
    document.getElementById('alert-title').focus();
}

function closeAlertModal() {
    document.getElementById('alert-modal').style.display = 'none';
    document.getElementById('alert-title').value = '';
    document.getElementById('alert-desc').value = '';
    document.getElementById('alert-severity').value = 'MEDIUM';
    document.getElementById('alert-location').value = '';
    document.getElementById('alert-helpline').value = '1363';
}

async function sendAlert() {
    const title = document.getElementById('alert-title').value.trim();
    const description = document.getElementById('alert-desc').value.trim();
    const severity = document.getElementById('alert-severity').value;
    const location = document.getElementById('alert-location').value.trim();
    const helplineNumber = document.getElementById('alert-helpline').value.trim();

    if (!title) { showToast('Title is required', 'error'); return; }
    if (!description) { showToast('Description is required', 'error'); return; }

    try {
        const res = await apiPost('/dashboard/api/alerts/create/', {
            title, description, severity, location, helplineNumber,
        });
        if (res.status === 'ok') {
            showToast('Alert broadcast successfully');
            closeAlertModal();
            setTimeout(() => location.reload(), 500);
        } else {
            showToast(res.error || 'Failed to broadcast', 'error');
        }
    } catch (e) {
        showToast('Network error', 'error');
    }
}

async function deactivateAlert(id) {
    try {
        await apiPost(`/dashboard/api/alerts/${id}/deactivate/`);
        showToast('Alert deactivated');
        setTimeout(() => location.reload(), 500);
    } catch (e) {
        showToast('Error deactivating alert', 'error');
    }
}

async function activateAlert(id) {
    try {
        await apiPost(`/dashboard/api/alerts/${id}/activate/`);
        showToast('Alert re-activated');
        setTimeout(() => location.reload(), 500);
    } catch (e) {
        showToast('Error activating alert', 'error');
    }
}

async function deleteAlert(id) {
    if (!confirm('Permanently delete this alert?')) return;
    try {
        await apiPost(`/dashboard/api/alerts/${id}/delete/`);
        showToast('Alert deleted');
        setTimeout(() => location.reload(), 500);
    } catch (e) {
        showToast('Error deleting alert', 'error');
    }
}
