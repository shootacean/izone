import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder)
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
  | SuccessItemTypes (List ItemType)
  | SuccessItems (List Item)
  | SuccessItemDependencies ItemDependencies



type alias ItemType =
    { id : Int, name : String }

type alias Item =
    { id : Int, name : String, description : String}

type alias ItemDependency =
    { id : Int, name : String, description : String, reason : String }

type alias ItemDependencies =
    { id : Int, name : String, description : String, dependecies : (List ItemDependency) }



init : () -> (Model, Cmd Msg)
init _ =
  ( Loading, getItems )



type Msg
  = GetItemTypes
  | GotItemTypes (Result Http.Error (List ItemType))
  | GetItems
  | GotItems (Result Http.Error (List Item))
  | GotItemDependencies (Result Http.Error ItemDependencies)
  | GetItemDependencies Int


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GetItemTypes ->
        ( model, getItemTypes )

    GetItems ->
        ( model, getItems )

    GetItemDependencies itemId ->
        ( model, getItemDependencies itemId )

    GotItemTypes result ->
      case result of
        Ok fullText ->
          (SuccessItemTypes fullText, Cmd.none)
        Err err ->
          Debug.log ( Debug.toString err )
          (Failure, Cmd.none)

    GotItems result ->
      case result of
        Ok fullText ->
          (SuccessItems fullText, Cmd.none)
        Err err ->
          Debug.log ( Debug.toString err )
          (Failure, Cmd.none)

    GotItemDependencies result ->
          case result of
            Ok fullText ->
              (SuccessItemDependencies fullText, Cmd.none)
            Err err ->
              Debug.log ( Debug.toString err )
              (Failure, Cmd.none)



view : Model -> Html Msg
view model =
    case model of
        Loading ->
          div [] [ text "Loading..." ]

        Failure ->
          div [] [ text "I was unable to load your resource." ]

        SuccessItemTypes itemTypes ->
          div []
              [ viewMenu
              , table []
                      [ tbody []
                              ( viewItemTypes itemTypes )
                      ]
              ]

        SuccessItems items ->
          div []
              [ viewMenu
              , table []
                      [ tbody []
                              ( viewItems items )
                      ]
              ]

        SuccessItemDependencies itemDependencies ->
          div []
              [ viewMenu
              , table []
                      [ tbody []
                              ( viewItemDependencies itemDependencies )
                      ]
              ]

viewMenu : Html Msg
viewMenu =
  div [] [ button [ onClick GetItems ] [ text "Items" ]
         , button [ onClick GetItemTypes ] [ text "ItemTypes" ]
         ]

viewItemTypes : (List ItemType) -> List (Html Msg)
viewItemTypes itemTypes =
  List.map
    (\itemType ->
      tr []
         [ td [] [ text ( String.fromInt itemType.id ) ]
         , td [] [ text itemType.name ]
         ]
    )
    itemTypes

viewItems : (List Item) -> List (Html Msg)
viewItems items =
  List.map
    (\item ->
      tr []
         [ td [] [ text ( String.fromInt item.id ) ]
         , td [] [ text item.name ]
         , td [] [ button [ onClick ( GetItemDependencies item.id )]
                          [ text "dependencies" ]
                 ]
         ]
    )
    items


viewItemDependencies : ItemDependencies -> List (Html Msg)
viewItemDependencies itemDependencies =
  List.map
    (\dep ->
      tr []
         [ td [] [ text ( String.fromInt dep.id ) ]
         , td [] [ text dep.name ]
         ]
    )
    itemDependencies.dependecies



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


getItems : Cmd Msg
getItems =
    Http.get
      { url = "http://localhost:8080/items"
      , expect = Http.expectJson GotItems itemsDecoder
      }

itemDecoder : Decoder Item
itemDecoder =
  Json.Decode.map3 Item
    (Json.Decode.field "id" Json.Decode.int)
    (Json.Decode.field "name" Json.Decode.string)
    (Json.Decode.field "description" Json.Decode.string)

itemsDecoder : Decoder (List Item)
itemsDecoder =
    Json.Decode.list itemDecoder


getItemDependencies : Int -> Cmd Msg
getItemDependencies itemId =
    Http.get
      { url = String.concat ["http://localhost:8080/item_dependencies?itemId=", String.fromInt(itemId) ]
      , expect = Http.expectJson GotItemDependencies itemDependenciesDecoder
      }

itemDependenciesDecoder : Decoder ItemDependencies
itemDependenciesDecoder =
    Json.Decode.map4 ItemDependencies
      (Json.Decode.field "id" Json.Decode.int)
      (Json.Decode.field "name" Json.Decode.string)
      (Json.Decode.field "description" Json.Decode.string)
      (Json.Decode.field "dependencies" (Json.Decode.list itemDependencyDecoder))

itemDependencyDecoder : Decoder ItemDependency
itemDependencyDecoder =
  Json.Decode.map4 ItemDependency
    (Json.Decode.field "id" Json.Decode.int)
    (Json.Decode.field "name" Json.Decode.string)
    (Json.Decode.field "description" Json.Decode.string)
    (Json.Decode.field "reason" Json.Decode.string)



subscriptions : Model -> Sub Msg
subscriptions model = Sub.none