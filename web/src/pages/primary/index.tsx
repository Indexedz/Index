import React from 'react'
import { Tab } from '@headlessui/react'
import useEState from '../../lib/hooks/useEState';
import { Character } from './typings/character';
import MirageSetup from './mirages/setup';

import CharactersPage from './pages/Characters'
import CreatorPage from './pages/Creator'

MirageSetup.mirage()

function classNames(...classes: any) {
  return classes.filter(Boolean).join(' ')
}

function index() {
  const [characters, , isLoading] = useEState<Character[]>([], "SetupCharacter");
  let [categories] = React.useState([
    { label: 'ตัวละคร', element: (characters: Character[], isLoading: boolean) => <CharactersPage characters={characters} isLoading={isLoading} /> },
    { label: 'สร้าง', element: (characters: Character[], isLoading: boolean) => <CreatorPage characters={characters} isLoading={isLoading} /> }
  ])

  return (
    <div className="w-96 border m-5 rounded bg-gray-200">
      <Tab.Group >
        <Tab.List className="flex p-0 m-0 space-x-0">
          {(categories).map((category) => (
            <Tab
              key={category.label}
              className={({ selected }) =>
                classNames(
                  'w-full py-2.5 text-blue-700 outline-none',
                  selected
                    ? 'bg-white shadow'
                    : 'text-blue-100 hover:bg-white/[0.12] hover:text-white'
                )
              }
            >
              {category.label}
            </Tab>
          ))}
        </Tab.List>
        <Tab.Panels>
          {
            (categories).map((category, index) => {
              return (
                <Tab.Panel key={index}>
                  {category.element(characters, isLoading)}
                </Tab.Panel>
              )
            })
          }
        </Tab.Panels>
      </Tab.Group>
    </div>
  )
}

export default index