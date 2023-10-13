import Mirage from "../../../lib/misc/mirage";
import { Location } from "../typings/location";

const Locations: Location[] = [
  {
    id: "57",
    label: "Seth Kim"
  },
  {
    id: "12",
    label: "Winnie McBride"
  },
  {
    id: "50",
    label: "Gordon Soto"
  },
  {
    id: "74",
    label: "Jorge Warner"
  }
]

const MirageSetup = new Mirage({
  header: "SetupLocations",
  props: Locations
})

export default MirageSetup