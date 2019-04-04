defmodule ExForce.Composite.SaveResultObject do
  @type t :: %__MODULE__{id: String.t() | nil, success: true | false, errors: list}
  defstruct [:id, :success, :errors]
end