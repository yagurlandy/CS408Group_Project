document.addEventListener('DOMContentLoaded', function () {
  const saveBtn = document.getElementById('savePlanBtn');
  if (!saveBtn) return;

  saveBtn.addEventListener('click', function () {
    const title = document.getElementById('newPlanTitle').value.trim();
    const desc  = document.getElementById('newPlanDesc').value.trim();
    const err   = document.getElementById('planModalError');
    err.classList.add('d-none');

    const csrf = document.querySelector('input[name="_csrf"]').value;
    const body = new URLSearchParams({ title, description: desc, _csrf: csrf });

    fetch('/plans/quick', { method: 'POST', body })
      .then(r => r.json())
      .then(data => {
        if (data.error) { err.textContent = data.error; err.classList.remove('d-none'); return; }
        const select = document.getElementById('plan_id');
        const opt = new Option(data.title, data.id, true, true);
        select.add(opt);
        bootstrap.Modal.getInstance(document.getElementById('newPlanModal')).hide();
        document.getElementById('newPlanTitle').value = '';
        document.getElementById('newPlanDesc').value  = '';
      })
      .catch(() => { err.textContent = 'Something went wrong.'; err.classList.remove('d-none'); });
  });
});
