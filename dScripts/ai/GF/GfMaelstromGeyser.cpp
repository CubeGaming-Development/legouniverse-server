#include "GfMaelstromGeyser.h"
#include "SkillComponent.h"

void GfMaelstromGeyser::OnStartup(Entity* self) {
	self->AddTimer(m_StartSkillTimerName, m_StartSkillTimerTime);
	self->AddTimer(m_KillSelfTimerName, m_KillSelfTimerTime);
}

void GfMaelstromGeyser::OnTimerDone(Entity* self, std::string timerName) {
	if (timerName == m_StartSkillTimerName) {
		auto* skillComponent = self->GetComponent<SkillComponent>();
		skillComponent->CalculateBehavior(m_SkillID, m_BehaviorID, LWOOBJID_EMPTY, true);
	}
	if (timerName == m_KillSelfTimerName) {
		self->Smash(LWOOBJID_EMPTY, eKillType::SILENT);
	}
}

