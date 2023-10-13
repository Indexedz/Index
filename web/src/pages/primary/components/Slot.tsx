import React from 'react';
import { Character } from '../typings/character';

interface SlotProps extends Character {
  setSelected: React.Dispatch<React.SetStateAction<string | null>>,
  selected: boolean
}

function Slot(props: SlotProps) {
  const onSelect = () => props.setSelected(props.id)

  const slotClass = `p-5 rounded hover:bg-gray-400 transition-all ${props.selected ? 'bg-gray-400' : 'bg-gray-300'}`;

  return (
    <div className={slotClass} onClick={onSelect}>
      <h2 className="pointer-events-none">{props.name}</h2>
    </div>
  )
}

export default Slot;
