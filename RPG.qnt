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
    /*
    pure val Creatures = Set(
        { id: 1 ,team: Character,class: Mage, hp: 20, immune: false, paralized: 0, taunted: 0, initiative: 0},
        { id: 2 ,team: Character,class: Cleric, hp: 20, immune: false, paralized: 0, taunted: 0, initiative: 0},
        { id: 3 ,team: Character,class: Barbaric, hp: 150, immune: false, paralized: 0, taunted: 0, initiative: 0},
        {id: 4, team: Monster, class: None, hp: 100, immune: false, paralized: 0, taunted: 0, initiative: 0}
    )*/

    var creatures: int -> Creature
    var nextCreature: int -> Creature

    pure def do_damage(c: Creature, d: int): Creature = {
        {...c, hp: c.hp - d}
    }
    pure def set_taunted(c: Creature, attackerId: int): Creature ={
        {...c, taunted: attackerId}
    }
    pure def remove_taunt(c: Creature): bool = {
        {...c, taunt: 0}
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

    action basic_attack(attacker: Creature, receiver: Creature): bool = {
        creatures' = creatures.setBy(receiver.id, creature => creature.do_damage(basic_damge)).setBy(attacker.id, creature => creature.remove_taunt())
    }

    action taunt(attacker: Creature, receiver: Creature): bool = {
        all{
            creatures' = creatures.setBy(receiver.id, receiver => receiver.set_taunted(attacker.id))
        }
    }
    action give_immunit(): bool = {
        creatures' = creatures.keys().mapBy(team => creatures.get(Character).set_immunit(true))
    }
    action strong_paralize(attacker: Creature, receiver: Creature): bool = {
        creatures' = creatures.setBy(receiver.id, creature => creature.set_paralized(-1)).setBy(attacker.id, creature => creature.remove_taunt())
    }
    action weak_paralize(receiver: Creature): bool = {
        creatures' = creatures.setBy(receiver.id, creature => creature.set_paralized(1))
    }
    action remove_paralize(): bool = all {
        creatures.filter(c => c.team == Character and c.paralized == 1) != Set(),
        nondet receiver = creatures.filter(c => c.team == Character and c.paralized == 1).oneOf()
        creatures' = creatures.setBy(receiver.id, creature => creature.set_paralized(0))

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
                | None => any { basic_attack(attacker, Newreceiver), strong_paralize(attacker ,Newreceiver) }  // Monster
                | Mage => any { basic_attack(attacker, Newreceiver), weak_paralize(Newreceiver), remove_paralize() }
                | Cleric => any { basic_attack(attacker, Newreceiver), give_immunit(), weak_paralize(Newreceiver), remove_paralize() }
                | Barbaric => any { basic_attack(attacker, Newreceiver), taunt(attacker, Newreceiver), weak_paralize(Newreceiver), remove_paralize() }
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
            round' = 0,
            creatures' = Map(
                1 -> { id: 1 ,team: Character,class: Mage, hp: 20, immune: false, paralized: 0, taunted: 0, initiative: mageInitiaive},
                2 -> { id: 2 ,team: Character,class: Cleric, hp: 20, immune: false, paralized: 0, taunted: 0, initiative: clericInitiaive},
                3 -> { id: 3 ,team: Character,class: Barbaric, hp: 150, immune: false, paralized: 0, taunted: 0, initiative: barbarianInitiaive},
                4 -> {id: 4, team: Monster, class: None, hp: 100, immune: false, paralized: 0, taunted: 0, initiative: monsterInitiaive}
            )
        }       
    }

    action step = {
        val attackers_by_initiative = creatures.values().toList((creature1, creature2) => intCompare(creature2.initiative, creature1.initiative))
        val attacker = attackers_by_initiative[round % creatures.keys().size()]
        val receiver = creatures.values().filter(c => attacker != c).oneOf()
        all {
            dumb_attack(attacker, receiver),
            round' = round + 1,
        }
    }

    //val inv = creatures.values().forall(c -> c.hp > 0)
}