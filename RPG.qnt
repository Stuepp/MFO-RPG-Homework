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
        paralized: bool,
        taunted: int
    }

    pure val Characters = Set(
        { id: 1 ,team: Character ,class: Mage, hp: 20, immune: false, paralized: false},
        { id: 2 ,team: Character ,class: Cleric, hp: 20, immune: false, paralized: false},
        { id: 3 ,team: Character ,class: Barbaric, hp: 150, immune: false, paralized: false}
    )
    pure val Monsters = Set(
        {id: 4, team: Monster, hp: 100, paralized: false, taunted: false}
    )

    var creatures: int -> Creature

    pure def do_damage(c: Creature, d: int): Creature = {
        {...c, hp: c.hp - d}
    }
    pure def check_life_status(attacker: Creature, receiver: Creature): bool = {
        all{ attacker != receiver, attacker.hp > 0, receiver.hp > 0 }
    }

    action basic_attack(receiver: Creature): bool = {
        creatures' = creatures.setBy(receiver.id, creature => creature.do_damage(basic_damge))
    }

    action taunt(attacker: Creature, receiver: Creature): bool = {
        all{
            creatures' = creatures.set(receiver.id, receiver.taunted = attacker.id)
        }
    }
    action give_immunit(): bool = {
        true
    }
    action dumb_attack(attacker: Creature, receiver: Creature): bool = {
        all{
            check_life_status(attacker, receiver),
            attacker.team != receiver.team,

            match attacker.team {
                | Monster => basic_attack(receiver)
                | Character => match attacker.class {
                    | Mage => basic_attack(receiver)
                    | Cleric => basic_attack(receiver)
                    | Barbaric => any { basic_attack(receiver), taunt(attacker, receiver) }
                }
            },
        }
    }

}