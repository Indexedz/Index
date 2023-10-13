import React from 'react';
import { Character } from '../typings/character';
import Loading from '../../../components/Loading';
import Slot from '../components/Slot';
import Confirmation from '../../../layouts/Confirmation';
import useFetch from '../../../lib/hooks/useFetch';
import { useNavigation } from '../../../lib/navigation/provider';

interface CharacterProps {
  characters: Character[],
  isLoading: boolean
}

function Characters({ characters, isLoading }: CharacterProps) {
  const [isConfirmation, setConfirmation] = React.useState<boolean>(false);
  const [selected, setSelected] = React.useState<string | null>(null);
  const {useNavigate} = useNavigation()

  const onPlay = () => {
    setConfirmation(true);
  }

  const onPlayConfirm = () => {
    useNavigate("loading")
    useFetch("SelectCharacter", characters.find((char) => char.id == selected), true)
    .then((status) => {
      useNavigate(status ? "hidden" : "primary")
    })
  }

  return (
    <>
      <Confirmation
        isOpen={isConfirmation}
        setOpen={setConfirmation}
        title='แจ้งเตือน'
        text='คุณต้องการเข้าเล่นหรือไม่?'
        onConfirm={onPlayConfirm}
      />
      <section className='mt-4 space-y-1 p-4 pt-0'>
        {
          isLoading ? (<Loading align='center' />) : (
            characters.length > 0 ? (
              characters.map((character) => {
                return <Slot
                  key={character.id}
                  setSelected={setSelected}
                  selected={selected == character.id}
                  {...character}
                />
              })
            ) : (
              <div className='text-center'>
                <i>ไม่พบตัวละคร</i>
              </div>
            )
          )
        }
      </section>

      {!isLoading && characters.length > 0 ? (
        <section className='p-4 pt-0'>
          <button
            onClick={onPlay}
            className='border bg-green-400 active:bg-green-500 transition-all w-full py-4 rounded uppercase disabled:bg-green-500'
            disabled={selected == null}
          >
            เล่น
          </button>
        </section>
      ) : (null)}
    </>
  )
}

export default Characters