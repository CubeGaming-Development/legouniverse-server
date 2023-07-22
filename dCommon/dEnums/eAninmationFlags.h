#pragma once

#ifndef __EANINMATIONFLAGS__H__
#define __EANINMATIONFLAGS__H__

#include <cstdint>

enum class eAnimationFlags : uint32_t {
	IDLE_NONE = 0,
	IDLE_BASIC,
	IDLE_SWIM,
	IDLE_CARRY,
	IDLE_SWORD,
	IDLE_HAMMER,
	IDLE_SPEAR,
	IDLE_PISTOL,
	IDLE_BOW,
	IDLE_COMBAT,
	IDLE_JETPACK,
	IDLE_HORSE,
	IDLE_SG,
	IDLE_ORGAN,
	IDLE_SKATEBOARD,
	IDLE_DAREDEVIL,
	IDLE_SAMURAI,
	IDLE_SUMMONER,
	IDLE_BUCCANEER,
	IDLE_MISC,
	IDLE_NINJA,
	IDLE_MISC1,
	IDLE_MISC2,
	IDLE_MISC3,
	IDLE_MISC4,
	IDLE_MISC5,
	IDLE_MISC6,
	IDLE_MISC7,
	IDLE_MISC8,
	IDLE_MISC9,
	IDLE_MISC10,
	IDLE_MISC11,
	IDLE_MISC12
};

#endif  //!__EANINMATIONFLAGS__H__
