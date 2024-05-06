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
        speed: int // initiative
    }

    pure val Characters = Set(
        { id: 1 ,team: Character ,class: Mage, hp: 20, immune: false, paralized: 0},
        { id: 2 ,team: Character ,class: Cleric, hp: 20, immune: false, paralized: 0},
        { id: 3 ,team: Character ,class: Barbaric, hp: 150, immune: false, paralized: 0}
    )
    pure val Monsters = Set(
        {id: 4, team: Monster, hp: 100, paralized: 0, taunted: -1}
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
    action dumb_attack(attacker: Creature, receiver: Creature): bool = {
        all{
            check_creature_status(attacker, receiver),
            
            val Newreceiver = if(attacker.taunted > 0){
              creatures.get(attacker.taunted)  
            }else{
                receiver
            }

            match attacker.class {
                | None => any { basic_attack(Newreceiver), strong_paralize(Newreceiver)}  // Monster
                | Mage => any { basic_attack(Newreceiver), weak_paralize(Newreceiver) }
                | Cleric => any { basic_attack(Newreceiver), give_immunit(), weak_paralize(Newreceiver) }
                | Barbaric => any { basic_attack(Newreceiver), taunt(attacker, Newreceiver), weak_paralize(Newreceiver) }
            },
        }
    }

    action init = {
        
        // check speed of each creature, sort highest to lower in a list
        }
    }

    action step = {
        val attacker = creatures.get()
        val receiver = creatures.get()
        all {
            dumb_attack(attacker, receiver),
            // next creature in the sorted list
            // a b c
            // a selected now list is b c a
        }
    }

    //val inv = creatures.values().forall(c -> c.hp > 0)
}