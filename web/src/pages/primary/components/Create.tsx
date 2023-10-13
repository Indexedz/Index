import React from 'react';
interface SlotProps  {
  setSelected: React.Dispatch<React.SetStateAction<string | null>>,
  selected: boolean
}

function Create(props: SlotProps) {
  const onSelect = () => props.setSelected("create")

  const slotClass = `p-5 rounded hover:bg-gray-400 transition-all ${props.selected ? 'bg-gray-400' : 'bg-gray-300'}`;

  return (
    <div className={slotClass} onClick={onSelect}>
      <h2 className="pointer-events-none text-center">CREATE</h2>
    </div>
  )
}

export default Create;
