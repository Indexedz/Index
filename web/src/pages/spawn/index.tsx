import React from 'react'
import { Location } from './typings/location'
import MirageSetup from './mirages/setup';
import useEState from '../../lib/hooks/useEState';
import { RadioGroup } from '@headlessui/react'
import Loading from '../../components/Loading';
import useFetch from '../../lib/hooks/useFetch';
import { useNavigation } from '../../lib/navigation/provider';
MirageSetup.mirage();

function SpawnLocation() {
  const [locations, , isLoading] = useEState<Location[]>([], "SetupLocations");
  let [location, setLocation] = React.useState<string>("")
  const { useNavigate } = useNavigation()

  React.useEffect(() => {
    if (locations.length <= 0) {
      return
    }

    setLocation(locations[0].id)
  }, [locations])

  React.useEffect(() => {
    useFetch("HoverLocation", location);
  }, [location])

  const onSelected = () => {
    useNavigate("loading")
    useFetch("SelectedLocation", location, true)
      .then((status) => {
        useNavigate(status ? "hidden" : "spawnLocation")
      })
  }

  return (
    <div className="w-96 border m-5 rounded bg-gray-200 p-4">
      <section className='p-4 pt-0 text-center'>
        <h1 className='text-xl'>สถานที่เริ่มต้น</h1>
      </section>
      <section>
        <RadioGroup
          value={location}
          onChange={setLocation}
          className="space-y-1"
        >
          {
            !isLoading ? (
              locations.map((location) => {
                return (
                  <RadioGroup.Option
                    key={location.id}
                    value={location.id}
                  >
                    {({ checked }) => (
                      <div className={`p-5 rounded cursor-pointer transition-all ${checked ? 'bg-gray-400' : 'bg-gray-300'}`}>
                        <h2 className="pointer-events-none">{location.label}</h2>
                      </div>
                    )}
                  </RadioGroup.Option>
                )
              })
            ) : (
              <div className='mt-2'>
                <Loading align='center' />
              </div>
            )
          }
        </RadioGroup>
      </section>
      <section>
        {!isLoading ? (
          <button
            onClick={onSelected}
            className='border bg-green-400 mt-2 active:bg-green-500 transition-all w-full py-4 rounded uppercase disabled:bg-green-700'
          >
            เลือก
          </button>
        ) : (null)}
      </section>
    </div>
  )
}

export default SpawnLocation