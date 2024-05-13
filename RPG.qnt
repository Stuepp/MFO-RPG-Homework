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
            // must have option to remove paralize, but how to get a reciver as someone paralized?
            // need to check if someone in the team is paralized, the if it adds the option to save
            // if no one is paralized there is no one to save.
            match attacker.class {
                | None => any { basic_attack(Newreceiver), strong_paralize(Newreceiver) }  // Monster
                | Mage => any { basic_attack(Newreceiver), weak_paralize(Newreceiver), remove_paralize() }
                | Cleric => any { basic_attack(Newreceiver), give_immunit(), weak_paralize(Newreceiver), remove_paralize }
                | Barbaric => any { basic_attack(Newreceiver), taunt(attacker, Newreceiver), weak_paralize(Newreceiver), remove_paralize }
            },
        }
    }

    action init = {
        val d20 = 1.to(20)
        nondet mageInitiaive = d20.oneOf()
        nondet clericInitiaive = d20.oneOf()
        nondet barbarianInitiaive = d20.oneOf()
        nondet monsterInitiaive = d20.oneOf()
        // with this Set, create a List sorted by the highest initiative to the lowest
        }
    }

    action step = {
        val attacker = creatures.get()
        val receiver = Creatures.oneOf()
        all {
            creatures' = [].indices().map(attacker => dumb_attack(attacker, receiver))
            // next creature in the sorted list | better to make a List of the Set Creatures and make a map to run the dumb_attack on each el
            // a b c
            // a selected now list is b c a
        }
    }

    //val inv = creatures.values().forall(c -> c.hp > 0)
}