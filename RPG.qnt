module RPG{
    import basicSpells.* from "./spells/basicSpells"
    import rareSpells.* from "./spells/rareSpells"

    type CreatureType = Character | Monster
    type Characeter_Class = Mage | Cleric | Barbaric | Danone

    pure val basic_damge = 10
    
    type Creature = {
        id: int,
        team: CreatureType,
        class: Characeter_Class,
        hp: int,
        immune: bool,
        paralized: int,
        taunted: int,
        initiative: int // initiative
    }

    type LastAttack = {
        attacker: Creature,
        receiver: Creature,
        attack: str
    }
    
    var creatures: int -> Creature
    var nextCreature: int -> Creature

    var last_attack: Option[LastAttack]

    pure def do_damage(c: Creature, d: int): Creature = {
        {...c, hp: c.hp - d}
    }
    pure def set_taunted(c: Creature, attackerId: int): Creature ={
        {...c, taunted: attackerId}
    }
    pure def remove_taunt(c: Creature): Creature = {
        {...c, taunted: 0}
    }
    pure def check_creature_status(attacker: Creature, receiver: Creature): bool = {
        all{ 
            attacker != receiver, 
            attacker.team != receiver.team, 
            attacker.hp > 0, receiver.hp > 0, 
            attacker.paralized == 0 
        }
    }
    pure def set_immunit(c: Creature, immnueStatus: bool): Creature = {
        {...c, immune: immnueStatus}
    }
    pure def set_paralized(c: Creature, paralizedRounds: int): Creature = {
        {...c, paralized: paralizedRounds}
    }
    pure def set_initiative(c: Creature, initiative: int):Creature = {
        {...c, initiative: initiative}
    }

    action basic_attack(attacker: Creature, receiver: Creature): bool = {
        all {
            creatures' = creatures.setBy(receiver.id, creature => creature.do_damage(basic_damge)).setBy(attacker.id, creature => creature.remove_taunt()),
            last_attack' = Some({attacker: attacker, receiver: receiver, attack: "basic_attack"})
        }
    }

    action taunt(attacker: Creature, receiver: Creature): bool = {
        all{
            creatures' = creatures.setBy(receiver.id, receiver => receiver.set_taunted(attacker.id)),
            last_attack' = Some({attacker: attacker, receiver: receiver, attack: "taunt"})
        }
    }
    action give_immunit(): bool = {
        all {
            creatures' = creatures.transformValues(c => if(c.team == Character) c.set_immunit(true) else c),
            last_attack' = last_attack
        }
    }
    action strong_paralize(attacker: Creature, receiver: Creature): bool = {
        all {
            creatures' = creatures.setBy(receiver.id, creature => creature.set_paralized(-1)).setBy(attacker.id, creature => creature.remove_taunt()),
            last_attack' = Some({attacker: attacker, receiver: receiver, attack: "strong_paralize"})
        }
    }
    action weak_paralize(attacker: Creature, receiver: Creature): bool = {
        all {
            creatures' = creatures.setBy(receiver.id, creature => creature.set_paralized(1)),
            last_attack' = Some({attacker: attacker, receiver: receiver, attack: "paralize"})
        }
    }
    action remove_paralize(): bool = all {
        creatures.values().filter(c => c.team == Character and c.paralized == 1) != Set(),
        nondet receiver = creatures.values().filter(c => c.team == Character and c.paralized == 1).oneOf()
        creatures' = creatures.setBy(receiver.id, creature => creature.set_paralized(0)),
        last_attack' = last_attack
        // creatures.transformValues(c => c.set_paralized(0))
    }
    action dumb_attack(attacker: Creature, receiver: Creature): bool = {
        all{
            check_creature_status(attacker, receiver),
            
            val Newreceiver = if(attacker.taunted > 0){
              creatures.get(attacker.taunted)
            }else{
                receiver
            }
            match attacker.class {
                | Danone => any { basic_attack(attacker, Newreceiver), strong_paralize(attacker ,Newreceiver) }  // Monster
                | Mage => any { basic_attack(attacker, Newreceiver), weak_paralize(attacker, Newreceiver), remove_paralize }
                | Cleric => any { basic_attack(attacker, Newreceiver), give_immunit, weak_paralize(attacker, Newreceiver), remove_paralize }
                | Barbaric => any { basic_attack(attacker, Newreceiver), taunt(attacker, Newreceiver), weak_paralize(attacker, Newreceiver), remove_paralize }
            },
        }
    }

    action smart_attack(attacker: Creature, receiver: Creature): bool = {
        all{
            check_creature_status(attacker, receiver),
            
            val Newreceiver = if(attacker.taunted > 0){
              creatures.get(attacker.taunted)
            }else{
                receiver
            }
            match attacker.class {
                | Danone => any { basic_attack(attacker, Newreceiver), strong_paralize(attacker ,Newreceiver) }  // Monster
                | Mage => basic_attack(attacker, Newreceiver)
                | Cleric => weak_paralize(attacker, Newreceiver)
                | Barbaric => basic_attack(attacker, Newreceiver)
            },
        }
    }

    var round: int

    action init = {
        val d20 = 1.to(20)
        nondet mageInitiaive = d20.oneOf()
        nondet clericInitiaive = d20.oneOf()
        nondet barbarianInitiaive = d20.oneOf()
        nondet monsterInitiaive = d20.oneOf()
        all {
            last_attack' = None,
            round' = 0,
            creatures' = Map(
                1 -> { id: 1 ,team: Character,class: Mage, hp: 20, immune: false, paralized: 0, taunted: 0, initiative: mageInitiaive},
                2 -> { id: 2 ,team: Character,class: Cleric, hp: 20, immune: false, paralized: 0, taunted: 0, initiative: clericInitiaive},
                3 -> { id: 3 ,team: Character,class: Barbaric, hp: 150, immune: false, paralized: 0, taunted: 0, initiative: barbarianInitiaive},
                4 -> {id: 4, team: Monster, class: Danone, hp: 100, immune: false, paralized: 0, taunted: 0, initiative: monsterInitiaive}
                //5 -> {id: 5, team: Monster, class: Danone, hp: 100, immune: false, paralized: 0, taunted: 0, initiative: monsterInitiaive}
            )
        }
    }

    action step = {
        val attackers_by_initiative = creatures.values().toList((creature1, creature2) => intCompare(creature2.initiative, creature1.initiative))
        val attacker = attackers_by_initiative[round % creatures.keys().size()]
        nondet receiver = creatures.values().filter(c => attacker.team != c.team).oneOf()
        all {
            dumb_attack(attacker, receiver),
            round' = round + 1,
        }
    }

    val noMonDies = creatures.values().forall(c => c.team == Monster and c.hp > 0)
    val noCharDies = creatures.values().forall(c => c.team == Character and c.hp > 0)
}