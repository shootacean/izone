import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Url
import Http
import Json.Decode exposing (Decoder)
import Debug



main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        }



type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , items : List Item
    , itemTypes : List ItemType
    , itemDependencies : ItemDependencies
    }


type alias ItemType =
    { id : Int, name : String }

type alias Item =
    { id : Int, name : String, description : String}

type alias ItemDependency =
    { id : Int, name : String, description : String, reason : String }

type alias ItemDependencies =
    { id : Int, name : String, description : String, dependecies : (List ItemDependency) }



init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        itemDep = ItemDependencies 0 "" "" []
    in
    Debug.log(url.path)
    changeRouteTo url ( Model key url [] [] itemDep )



type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url.Url
    | GotItemsMsg (Result Http.Error (List Item))
    | GotItemTypesMsg (Result Http.Error (List ItemType))
    | GotItemDependenciesMsg (Result Http.Error ItemDependencies)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ClickedLink urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ChangedUrl url ->
            changeRouteTo url model

        GotItemsMsg result ->
            case result of
                Ok items ->
                    ( { model | items = items} , Cmd.none )
                Err err ->
                    Debug.log ( Debug.toString err )
                    ( model, Cmd.none )

        GotItemTypesMsg result ->
            case result of
                Ok itemTypes ->
                    ( { model | itemTypes = itemTypes } , Cmd.none )
                Err err ->
                    Debug.log ( Debug.toString err )
                    ( model, Cmd.none )

        GotItemDependenciesMsg result ->
            case result of
                Ok itemDependencies ->
                    ( { model | itemDependencies = itemDependencies } , Cmd.none )
                Err err ->
                    Debug.log ( Debug.toString err )
                    ( model, Cmd.none )


changeRouteTo : Url.Url -> Model -> ( Model, Cmd Msg )
changeRouteTo url model =
    case url.path of
        "/src/items" ->
            ( { model | url = url }, getItems )
        "/src/item_types" ->
            ( { model | url = url }, getItemTypes )
        "/src/item_dependencies" ->
            ( { model | url = url }, getItemDependencies 19 )
        _ ->
            ( { model | url = url }, Cmd.none )



view : Model -> Browser.Document Msg
view model =
    case model.url.path of
        "/src/items" ->
            viewItemsPage model
        "/src/item_types" ->
            viewItemTypesPage model
        "/src/item_dependencies" ->
            viewItemDependenciesPage model
        _ ->
            viewHomePage model

viewHomePage : Model -> Browser.Document Msg
viewHomePage model =
    { title = "Izone | Items"
    , body =
        [ h1 [] [ text "Welcome Izone!" ]
        , h2 [] [ text "Home!" ]
        , a [ href "items" ] [ text "Items" ]
        , text " | "
        , a [ href "item_types" ] [ text "ItemTypes" ]
        , text " | "
        , a [ href "item_dependencies" ] [ text "ItemDependencies" ]
        ]
    }

viewItemsPage : Model -> Browser.Document Msg
viewItemsPage model =
    { title = "Izone | Items"
    , body =
        [ h1 [] [ text "Welcome Izone!" ]
        , h2 [] [ text "Items!" ]
        , a [ href "home" ] [ text "Home" ]
        , text " | "
        , a [ href "item_types" ] [ text "ItemTypes" ]
        , text " | "
        , a [ href "item_dependencies" ] [ text "ItemDependencies" ]
        , hr [] []
        , viewItemList model.items
        ]
    }

viewItemList : List Item -> Html Msg
viewItemList items =
    table []
          [ thead []
                  [ tr []
                       [ th [] [ text "Id" ]
                       , th [] [ text "Name" ]
                       , th [] [ text "Description" ]
                       , th [] [ text "" ]
                       ]
                  ]
          , tbody [] ( viewItemRow items )
          ]

viewItemRow : List Item -> List ( Html Msg )
viewItemRow items =
  List.map
    (\item ->
      tr []
         [ td [] [ text ( String.fromInt item.id ) ]
         , td [] [ text item.name ]
         , td [] [ text item.description ]
         , a [ href (String.concat ["item_dependencies?id=", String.fromInt item.id ]) ]
             [ text "Dependencies" ]
         ]
    )
    items


viewItemTypesPage : Model -> Browser.Document Msg
viewItemTypesPage model =
   { title = "Izone | Items"
   , body =
        [ h1 [] [ text "Welcome Izone!" ]
        , h2 [] [ text "ItemTypes!" ]
        , a [ href "home" ] [ text "Home" ]
        , text " | "
        , a [ href "items" ] [ text "Items" ]
        , text " | "
        , a [ href "item_dependencies" ] [ text "ItemDependencies" ]
        , viewItemTypeTable model.itemTypes
        ]
   }

viewItemTypeTable : List ItemType -> Html Msg
viewItemTypeTable itemTypes =
    table []
          [ thead []
                  [ tr []
                       [ th [] [ text "Id" ]
                       , th [] [ text "Name" ]
                       , th [] [ text "Description" ]
                       , th [] [ text "" ]
                       ]
                  ]
          , tbody [] ( viewItemTypeRow itemTypes )
          ]

viewItemTypeRow : List ItemType -> List ( Html Msg )
viewItemTypeRow itemTypes =
  List.map
    (\itemType ->
      tr []
         [ td [] [ text ( String.fromInt itemType.id ) ]
         , a [ href (String.concat ["item_types?id=", String.fromInt itemType.id ]) ]
             [ text itemType.name ]
         ]
    )
    itemTypes


viewItemDependenciesPage : Model -> Browser.Document Msg
viewItemDependenciesPage model =
   { title = "Izone | Item Dependencies"
   , body =
        [ h1 [] [ text "Welcome Izone!" ]
        , h2 [] [ text "ItemTypes!" ]
        , a [ href "home" ] [ text "Home" ]
        , text " | "
        , a [ href "items" ] [ text "Items" ]
        , text " | "
        , a [ href "item_types" ] [ text "ItemTypes" ]
        , viewItemDependenciesTable model.itemDependencies.dependecies
       ]
   }

viewItemDependenciesTable : List ItemDependency -> Html Msg
viewItemDependenciesTable dependencies =
    table []
          [ thead []
                  [ tr []
                       [ th [] [ text "Id" ]
                       , th [] [ text "Name" ]
                       , th [] [ text "Description" ]
                       , th [] [ text "" ]
                       ]
                  ]
          , tbody [] ( viewItemDependenciesRow dependencies )
          ]

viewItemDependenciesRow : List ItemDependency -> List ( Html Msg )
viewItemDependenciesRow dependencies =
  List.map
    (\dep ->
      tr []
         [ td [] [ text ( String.fromInt dep.id ) ]
         , td [] [ a [ href (String.concat ["items?id=", String.fromInt dep.id ]) ]
                     [ text dep.name ]
                 ]
         , td [] [ text dep.description ]
         , td [] [ a [ href (String.concat ["item_dependencies?id=", String.fromInt dep.id ]) ]
                     [ text "Dependencies" ]
                 ]
         ]
    )
    dependencies



getItems : Cmd Msg
getItems =
    Http.get
        { url = "http://localhost:8080/items"
        , expect = Http.expectJson GotItemsMsg itemsDecoder
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


getItemTypes : Cmd Msg
getItemTypes =
    Http.get
        { url = "http://localhost:8080/item_types"
        , expect = Http.expectJson GotItemTypesMsg itemTypesDecoder
        }

itemTypeDecoder : Decoder ItemType
itemTypeDecoder =
  Json.Decode.map2 ItemType
    (Json.Decode.field "id" Json.Decode.int)
    (Json.Decode.field "name" Json.Decode.string)

itemTypesDecoder : Decoder (List ItemType)
itemTypesDecoder =
    Json.Decode.list itemTypeDecoder


getItemDependencies : Int -> Cmd Msg
getItemDependencies itemId =
    Http.get
      { url = String.concat ["http://localhost:8080/item_dependencies?itemId=", String.fromInt(itemId) ]
      , expect = Http.expectJson GotItemDependenciesMsg itemDependenciesDecoder
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