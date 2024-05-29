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

    action skip_turn(attacker: Creature, receiver: Creature): bool = {
        all {
            val c = if(attacker.paralized == 1) {...attacker, paralized: 0} else attacker
            creatures' = creatures.setBy(attacker.id, creature => c),
            last_attack' = Some({attacker: attacker, receiver: receiver, attack:"skip_turn"})
        }
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
    
    action remove_paralize(attacker: Creature): bool = all {
        if(creatures.values().filter(c => c.team == Character and c.paralized != 0) != Set()) {
            nondet receiver = creatures.values().filter(c => c.team == Character and c.paralized != 0).oneOf()  
            val receiverP = creatures.get(receiver.id)
            all {
                creatures' = creatures.setBy(receiver.id, creature => creature.set_paralized(0)),
                last_attack' = Some({attacker: attacker, receiver: receiverP, attack: "remove_paralize"})
            }   
            // creatures.transformValues(c => c.set_paralized(0))
        }else{
            all {
                creatures' = creatures,
                last_attack' = last_attack
            }
        }
    }
    action dumb_attack(attacker: Creature, receiver: Creature): bool = {
        all{
            check_creature_status(attacker, receiver),
            
            val Newreceiver = if(attacker.taunted > 0 and creatures.get(attacker.taunted).hp > 0 and creatures.get(attacker.taunted).team != attacker.team ){
              creatures.get(attacker.taunted)
            }else{
                receiver
            }

            if(attacker.paralized != 0){
                skip_turn(attacker, receiver)
            }else{
                match attacker.class {
                    | Danone => any { basic_attack(attacker, Newreceiver), strong_paralize(attacker ,Newreceiver) }  // Monster
                    | Mage => any { basic_attack(attacker, Newreceiver), weak_paralize(attacker, Newreceiver), remove_paralize(attacker) }
                    | Cleric => any { basic_attack(attacker, Newreceiver), give_immunit, remove_paralize(attacker) }
                    | Barbaric => any { basic_attack(attacker, Newreceiver), taunt(attacker, Newreceiver), remove_paralize(attacker) }
                }
            }
        }
    }

    action smart_attack(attacker: Creature, receiver: Creature): bool = {
        all{
            check_creature_status(attacker, receiver),
            
            val Newreceiver = if(attacker.taunted > 0 and creatures.get(attacker.taunted).hp > 0 and creatures.get(attacker.taunted).team != attacker.team ){
              creatures.get(attacker.taunted)
            }else{
                receiver
            }

            if(attacker.paralized != 0){
                skip_turn(attacker, receiver)
            }else{
                if(attacker.team == Character and creatures.get(1).paralized != 0){
                    match attacker.class {
                    | Danone => any { basic_attack(attacker, Newreceiver), strong_paralize(attacker ,Newreceiver) }  // Monster
                    | Mage => any{ weak_paralize(attacker, Newreceiver)}
                    | Cleric => any{remove_paralize(attacker)}
                    | Barbaric => any{remove_paralize(attacker)}
                    }
                }else {
                    match attacker.class {
                    | Danone => any { basic_attack(attacker, Newreceiver), strong_paralize(attacker ,Newreceiver) }  // Monster
                    | Mage => any{ weak_paralize(attacker, Newreceiver)}
                    | Cleric => any{remove_paralize(attacker)}
                    | Barbaric => any{basic_attack(attacker, Newreceiver) }
                    }
                }
                
            }
        }
    }

    var round: int

    action init = {
        val d20 = 1.to(20)
        nondet mageInitiaive = d20.oneOf()
        nondet clericInitiaive = d20.oneOf()
        nondet barbarianInitiaive = d20.oneOf()
        nondet monsterInitiaive = d20.oneOf()
        nondet monsterInitiaive2 = d20.oneOf()
        all {
            last_attack' = None,
            round' = 0,
            creatures' = Map(
                1 -> { id: 1 ,team: Character,class: Mage, hp: 20, immune: false, paralized: 0, taunted: 0, initiative: mageInitiaive},
                2 -> { id: 2 ,team: Character,class: Cleric, hp: 20, immune: false, paralized: 0, taunted: 0, initiative: clericInitiaive},
                3 -> { id: 3 ,team: Character,class: Barbaric, hp: 150, immune: false, paralized: 0, taunted: 0, initiative: barbarianInitiaive},
                4 -> {id: 4, team: Monster, class: Danone, hp: 100, immune: false, paralized: 0, taunted: 0, initiative: monsterInitiaive},
                5 -> {id: 5, team: Monster, class: Danone, hp: 100, immune: false, paralized: 0, taunted: 0, initiative: monsterInitiaive2}
            )
        }
    }

    action step = {
        val attackers_by_initiative = creatures.values().toList((creature1, creature2) => intCompare(creature2.initiative, creature1.initiative))
        val attacker = attackers_by_initiative[round % creatures.keys().size()]
        nondet receiver = creatures.values().filter(c => attacker.team != c.team).oneOf()
        all {
            smart_attack(attacker, receiver),
            round' = round + 1,
        }
    }

    val noMonDies = creatures.values().filter(c => c.team == Monster).forall(c => c.hp > 0)
    val noCharDies = creatures.values().filter(c => c.team == Character).forall(c => c.hp > 0)
}