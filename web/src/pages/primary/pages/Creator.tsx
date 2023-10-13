import React, { FormEvent } from 'react';
import { Character } from '../typings/character';
import Loading from '../../../components/Loading';
import Confirmation from '../../../layouts/Confirmation';
import useFetch from '../../../lib/hooks/useFetch';
import { useNavigation } from '../../../lib/navigation/provider';
interface CreatorPageProps {
  characters: Character[],
  isLoading: boolean
}

const Field = (props: {
  label: string,
  name: string,
  state: string,
  setState: React.Dispatch<React.SetStateAction<string>>
}) => {
  const onChanged = (e: React.ChangeEvent<HTMLInputElement>) => {
    props.setState(e.target.value)
  }

  return (
    <div>
      <label htmlFor={props.name}>{props.label}</label>
      <input
        type="text"
        name={props.name}
        value={props.state}
        onChange={onChanged}
        className='outline-none p-2 py-1.5 rounded w-full'
        required
      />
    </div>
  )
}

function Creator({ characters, isLoading }: CreatorPageProps) {
  const { useNavigate } = useNavigation();
  const [isConfirmation, setConfirmation] = React.useState<boolean>(false);
  const [firstName, setFirstName] = React.useState<string>("")
  const [lastName, setLastName] = React.useState<string>("")
  const [birthday, setBirthday] = React.useState<string>("")
  const [gender, setGender] = React.useState<number>(0)
  
  const onFormSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setConfirmation(true);
  }

  const onCreate = () => {
    useNavigate("loading")
    useFetch("CreateCharacter", { firstName, lastName, birthday, gender }, true)
    .then((status) => {
      console.log('callback data', status);
      
      useNavigate(status ? "spawnLocation" : "primary")
    })
  }

  if (isLoading) {
    return (
      <>
        <section className='mt-4 space-y-1 p-4 pt-0'>
          <Loading align='center' />
        </section>
      </>
    )
  }

  return (
    <>
      <Confirmation
        isOpen={isConfirmation}
        setOpen={setConfirmation}
        title='แจ้งเตือน'
        text='คุณต้องการสร้างตัวละครใหม่หรือไม่ ?'
        onConfirm={onCreate}
      />

      <section className='mt-4 space-y-1 p-4 pt-0'>
        {characters.length <= 0 ? (
          <form className='space-y-2' onSubmit={onFormSubmit}>
            <Field name='firstName' label='ชื่อ : ' state={firstName} setState={setFirstName} />
            <Field name='lastName' label='นามสกุล : ' state={lastName} setState={setLastName} />
            <div>
              <label htmlFor="bd">วันเกิด :</label>
              <input
                type="date"
                name="bd"
                id="bd"
                max={new Date().toJSON().slice(0, 10)}
                className='w-full p-2 py-1.5 rounded'
                onChange={(e) => {
                  setBirthday(e.target.value)
                }}
                required
              />
            </div>
            <div>
              <label htmlFor="gender">เพศสภาพ : </label>
              <select
                name='gender'
                className='w-full p-2 py-1.5 rounded'
                value={gender}
                required
                onChange={(e) => {
                  setGender(Number(e.target.value))
                }}
              >
                <option value="0">ชาย</option>
                <option value="1">หญิง</option>
              </select>
            </div>
            <div>
              <button
                type='submit'
                className='border bg-green-400 active:bg-green-500 transition-all w-full py-4 rounded uppercase disabled:bg-green-700'
              >
                สร้างตัวละคร
              </button>
            </div>
          </form>
        ) : (
          <div className='text-center'>
            <i>คุณไม่สามารถสร้างตัวละครเพิ่มได้</i>
          </div>
        )}
      </section >
    </>
  )
}

export default Creator