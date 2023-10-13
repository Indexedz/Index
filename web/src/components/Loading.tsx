type align = "left" | "center" | "right";

function Loading(props: { align: align }) {
  return (
    <div
      className={
        props.align == "left" ? "text-left" : 
        props.align == "center" ? "text-center" : "text-right"
      }
    >
      <div
        className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-gray-400 border-solid border-current border-r-transparent align-[-0.125em] motion-reduce:animate-[spin_1.5s_linear_infinite]"
      >
        <span
          className="!absolute !-m-px !h-px !w-px !overflow-hidden !whitespace-nowrap !border-0 !p-0 ![clip:rect(0,0,0,0)]"
        >
          Loading...
        </span>
      </div>
    </div >
  )
}

export default Loading