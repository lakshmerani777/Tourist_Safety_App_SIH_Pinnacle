from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()


class TouristDigitalID(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='digital_id',
    )
    did               = models.CharField(max_length=120, unique=True, db_index=True)
    credential_id_hex = models.CharField(max_length=68, unique=True)
    data_hash_hex     = models.CharField(max_length=68)
    tx_hash           = models.CharField(max_length=68)
    issued_at         = models.DateTimeField()
    entry_point       = models.CharField(max_length=200, default='app_onboarding')
    is_active         = models.BooleanField(default=True)
    created_at        = models.DateTimeField(auto_now_add=True)
    updated_at        = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Tourist Digital ID'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.user.email} — {self.did}"

    @property
    def sepolia_explorer_url(self):
        return f"https://sepolia.etherscan.io/tx/{self.tx_hash}"
