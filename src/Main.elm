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
  | SuccessDependencyItems (List DependencyItem)



type alias ItemType =
    { id : Int, name : String }

type alias Item =
    { id : Int, name : String, description : String, typeId : Int, typeName : String }

--type alias DependencyItem =
--    { id : Int, name : String }



init : () -> (Model, Cmd Msg)
init _ =
  ( Loading, getItems )



type Msg
  = GetItemTypes
  | GotItemTypes (Result Http.Error (List ItemType))
  | GetItems
  | GotItems (Result Http.Error (List Item))
  | GetDependencyItems
  | GotDependencyItems (Result Http.Error (List DependencyItem))
  | GetItemDependencies Int


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GetItemTypes ->
        ( model, getItemTypes )

    GetItems ->`
        ( model, getItems )

    GetDependencyItems ->
        ( model, getDependencyItems )

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

    GotDependencyItems result ->
          case result of
            Ok fullText ->
              (SuccessDependencyItems fullText, Cmd.none)
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

        SuccessDependencyItems dependencyItems ->
          div []
              [ viewMenu
              , table []
                      [ tbody []
                              ( viewDependencyItems dependencyItems )
                      ]
              ]

viewMenu : Html Msg
viewMenu =
  div [] [ button [ onClick GetItems ] [ text "Items" ]
         , button [ onClick GetItemTypes ] [ text "ItemTypes" ]
         , button [ onClick GetDependencyItems ] [ text "DependencyItems" ]
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
         , td [] [ text ( String.fromInt item.typeId ) ]
         , td [] [ button [ onClick ( GetItemDependencies item.id )]
                          [ text "dependencies" ]
                 ]
         ]
    )
    items

viewDependencyItems : (List DependencyItem) -> List (Html Msg)
viewDependencyItems dependencyItems =
  List.map
    (\dependencyItem ->
      tr []
         [ td [] [ text ( String.fromInt dependencyItem.id ) ]
         , td [] [ text dependencyItem.name ]
         ]
    )
    dependencyItems



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
  Json.Decode.map5 Item
    (Json.Decode.field "id" Json.Decode.int)
    (Json.Decode.field "name" Json.Decode.string)
    (Json.Decode.field "description" Json.Decode.string)
    (Json.Decode.field "typeId" Json.Decode.int)
    (Json.Decode.field "typeName" Json.Decode.string)

itemsDecoder : Decoder (List Item)
itemsDecoder =
    Json.Decode.list itemDecoder


getDependencyItems : Cmd Msg
getDependencyItems =
    Http.get
      { url = "http://localhost:8080/item_dependencies"
      , expect = Http.expectJson GotDependencyItems dependencyItemsDecoder
      }

dependencyItemDecoder : Decoder DependencyItem
dependencyItemDecoder =
  Json.Decode.map2 DependencyItem
    (Json.Decode.field "id" Json.Decode.int)
    (Json.Decode.field "name" Json.Decode.string)

dependencyItemsDecoder : Decoder (List DependencyItem)
dependencyItemsDecoder =
    Json.Decode.list dependencyItemDecoder


getItemDependencies : Int -> Cmd Msg
getItemDependencies itemId =
    Http.get
      { url = String.concat ["http://localhost:8080/item_dependencies?itemId=", String.fromInt(itemId) ]
      , expect = Http.expectJson GotDependencyItems dependencyItemsDecoder
      }



subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none