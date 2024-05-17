module RPG{

    type CreatureType = Character | Monster
    type Characeter_Class = Mage | Cleric | Barbaric | None

    pure val basic_damge = 10
    
    type Creature = {
        id: int,
        team: CreatureType,
        class: Characeter_Class,
        hp: int,
        immnue: bool,
        paralized: int,
        taunted: int,
        initiative: int // initiative
    }

    pure val Creatures = Set(
        { id: 1 ,team: Character,class: Mage, hp: 20, immune: false, paralized: 0, taunted: 0, initiative: 0},
        { id: 2 ,team: Character,class: Cleric, hp: 20, immune: false, paralized: 0, taunted: 0, initiative: 0},
        { id: 3 ,team: Character,class: Barbaric, hp: 150, immune: false, paralized: 0, taunted: 0, initiative: 0},
        {id: 4, team: Monster, class: None, hp: 100, immune: false, paralized: 0, taunted: 0, initiative: 0}
    )

    var creatures: int -> Creature
    var nextCreature: int -> Creature

    pure def do_damage(c: Creature, d: int): Creature = {
        {...c, hp: c.hp - d}
    }
    pure def set_taunted(c: Creature, attackerId: int): Creature ={
        {...c, taunted: attackerId}
    }
    pure def check_creature_status(attacker: Creature, receiver: Creature): bool = {
        all{ attacker != receiver, attacker.team != receiver.team, attacker.hp > 0, receiver.hp > 0, attacker.paralized == 0 }
    }
    pure def set_immunit(c: Creature, immnueStatus: bool): Creature = {
        {...c, immnue: immnueStatus}
    }
    pure def set_paralized(c: Creature, paralizedRounds: int): Creature = {
        {...c, paralized: paralizedRounds}
    }
    pure def set_initiative(c: Creature, initiative: int):Creature = {
        {...c, initiative: initiative}
    }

    action basic_attack(receiver: Creature): bool = {
        creatures' = creatures.setBy(receiver.id, creature => creature.do_damage(basic_damge))
    }

    action taunt(attacker: Creature, receiver: Creature): bool = {
        all{
            creatures' = creatures.setBy(receiver.id, receiver => receiver.set_taunted(attacker.id))
        }
    }
    action remove_taunt(c: Creature): bool = {
        all{
            creatures' = creatures.setBy(c.id, c => c.set_taunted(0))
        }
    }
    action give_immunit(): bool = {
        creatures' = creatures.keys().mapBy(team => creatures.get(Character).set_immunit(true))
    }
    action strong_paralize(receiver: Creature): bool = {
        creatures' = creatures.setBy(receiver.id, creature => creature.set_paralized(-1))
    }
    action weak_paralize(receiver: Creature): bool = {
        creatures' = creatures.setBy(receiver.id, creature => creature.set_paralized(1))
    }
    action remove_paralize(): bool = all {
        Creatures.filter(c => c.team == Character and c.paralized == 1) != Set(),
        nondet receiver = Creatures.filter(c => c.team == Character and c.paralized == 1).oneOf()
        creatures' = creatures.setBy(receiver.id, creature => creature.set_paralized(0))
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
                | None => any { basic_attack(Newreceiver), strong_paralize(Newreceiver) }  // Monster
                | Mage => any { basic_attack(Newreceiver), weak_paralize(Newreceiver), remove_paralize() }
                | Cleric => any { basic_attack(Newreceiver), give_immunit(), weak_paralize(Newreceiver), remove_paralize() }
                | Barbaric => any { basic_attack(Newreceiver), taunt(attacker, Newreceiver), weak_paralize(Newreceiver), remove_paralize() }
            },
            remove_taunt(attacker)
        }
    }

    action init = {
        val d20 = 1.to(20)
        nondet mageInitiaive = d20.oneOf()
        nondet clericInitiaive = d20.oneOf()
        nondet barbarianInitiaive = d20.oneOf()
        nondet monsterInitiaive = d20.oneOf()
        val initiativeList = [mageInitiaive, clericInitiaive, barbarianInitiaive, monsterInitiaive]
        nextCreature' = 0
        /*
        all {
            /*
            creatures' = creatures.setBy(1, c => c.initiative = mageInitiaive)
            creatures' = creatures.setBy(2, c => c.initiative = clericInitiaive)
            creatures' = creatures.setBy(3, c => c.initiative = barbarianInitiaive)
            creatures' = creatures.setBy(4, c => c.initiative = monsterInitiaive)
            
        }*/
        // with this Set, create a List sorted by the highest initiative to the lowest
    }

    action step = {
        val attacker = creatures.get(initiativeList.nth(0))
        val receiver = creatures.oneOf(Creatures.filter(not (attacker.team)))
        val newNextCreature = if(nextCreature >= 3){
            nextCreature' = 0
            }else{
                nextCreature' = nextCreature + 1
            }
        all {
            dumb_attack(attacker, receiver)
            nextCreature' = newNextCreature
        }
    }

    //val inv = creatures.values().forall(c -> c.hp > 0)
}