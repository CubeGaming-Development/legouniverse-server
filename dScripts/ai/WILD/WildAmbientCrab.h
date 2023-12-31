#pragma once
#include "CppScripts.h"

class WildAmbientCrab final : public CppScripts::Script {
public:
	void OnStartup(Entity* self) override;
	void OnTimerDone(Entity* self, std::string timerName) override;
	void OnUse(Entity* self, Entity* user) override;
};
