import Browser
import Html exposing (..)
import Http
import Json.Decode exposing (Decoder, field, string)
import Debug

main =
    Browser.element
      { init = init
      , update = update
      , subscriptions = subscriptions
      , view = view
      }

type Model
  = Failure
  | Loading
  | Success (List ItemType)

type alias ItemType =
    { id : Int, name : String }

init : () -> (Model, Cmd Msg)
init _ =
  ( Loading, getItemTypes )


type Msg
  = GotItemTypes (Result Http.Error (List ItemType))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotItemTypes result ->
      case result of
        Ok fullText ->
          (Success fullText, Cmd.none)

        Err err ->
          Debug.log ( Debug.toString err )
          (Failure, Cmd.none)


view : Model -> Html Msg
view model =
    case model of
        Loading ->
          text "Loading..."

        Failure ->
          text "I was unable to load your resource."

        Success itemTypes ->
          div []
              [ table []
                      [ tbody [] ( viewItemTypes itemTypes ) ]
              ]

viewItemTypes : (List ItemType) -> List (Html msg)
viewItemTypes itemTypes =
  List.map
    (\itemType ->
      tr []
         [ td [] [ text ( String.fromInt itemType.id ) ]
         , td [] [ text itemType.name ]
         ]
    )
    itemTypes


getItemTypes : Cmd Msg
getItemTypes =
    Http.get
      { url = "http://localhost:8080/item_types"
      , expect = Http.expectJson GotItemTypes itemTypesDecoder
      }

itemTypeDecoder : Decoder ItemType
itemTypeDecoder =
  Json.Decode.map2 ItemType
    (Json.Decode.field "id" Json.Decode.int)
    (Json.Decode.field "name" Json.Decode.string)

itemTypesDecoder : Decoder (List ItemType)
itemTypesDecoder =
    Json.Decode.list itemTypeDecoder


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none