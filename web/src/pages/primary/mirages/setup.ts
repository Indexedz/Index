import Mirage from "../../../lib/misc/mirage";
import { Character } from "../typings/character";

const Characters: Character[] = [
  {
    id: "57",
    name: "Seth Kim"
  },
  {
    id: "12",
    name: "Winnie McBride"
  },
  {
    id: "50",
    name: "Gordon Soto"
  },
  {
    id: "74",
    name: "Jorge Warner"
  }
]

const MirageSetup = new Mirage({
  header: "SetupCharacter",
  props: Characters
})

export default MirageSetup