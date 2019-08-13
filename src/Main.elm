import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Url
import Url.Parser as Parser exposing (Parser, (</>), (<?>))
import Url.Parser.Query as Query
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
    , route : Maybe Route
    , items : List Item
    , item : Item
    , itemTypes : List ItemType
    , itemDependencies : ItemDependencies
    , itemDepended : ItemDependencies
    }


type alias ItemType =
    { id : Int, name : String }

type alias Item =
    { id : Int, name : String, description : String}

type alias ItemDependency =
    { id : Int, name : String, description : String, reason : String }

type alias ItemDependencies =
    { id : Int, name : String, description : String, dependecies : (List ItemDependency) }



-- ROUTER

type Route
    = HomeRoute
    | ItemsRoute
    | ItemRoute Int
    | ItemTypesRoute

routeParser : Parser ( Route -> a ) a
routeParser =
    Parser.oneOf
        [ Parser.map HomeRoute Parser.top
        , Parser.map ItemsRoute ( Parser.s "items" )
        , Parser.map ItemRoute ( Parser.s "items" </> Parser.int )
        , Parser.map ItemTypesRoute ( Parser.s "item_types" )
        ]

fromUrl : Url.Url -> Maybe Route
fromUrl url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Parser.parse routeParser



init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        item = Item 0 "" ""
        itemDep = ItemDependencies 0 "" "" []
        itemDeped = ItemDependencies 0 "" "" []
    in
    changeRouteTo (fromUrl url) ( Model key (Just HomeRoute) [] item [] itemDep itemDeped)



type Msg
    = ClickedLink Browser.UrlRequest
    | ChangedUrl Url.Url
    | GotItemsMsg (Result Http.Error (List Item))
    | GotItemMsg (Result Http.Error Item)
    | GotItemTypesMsg (Result Http.Error (List ItemType))
    | GotItemDependenciesMsg (Result Http.Error ItemDependencies)
    | GotItemDependedMsg (Result Http.Error ItemDependencies)

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
            Debug.log( Debug.toString(fromUrl url) )
            changeRouteTo (fromUrl url) model

        GotItemsMsg result ->
            case result of
                Ok items ->
                    ( { model | items = items} , Cmd.none )
                Err err ->
                    Debug.log ( Debug.toString err )
                    ( model, Cmd.none )

        GotItemMsg result ->
            case result of
                Ok item ->
                    ( { model | item = item} , getItemDependencies item.id )
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
                    ( { model | itemDependencies = itemDependencies } , getItemDepended itemDependencies.id )
                Err err ->
                    let
                        itemDependencies = ItemDependencies 0 "" "" []
                    in
                    Debug.log ( Debug.toString err )
                    ( { model | itemDependencies = itemDependencies }, Cmd.none )

        GotItemDependedMsg result ->
            case result of
                Ok itemDependencies ->
                    ( { model | itemDepended = itemDependencies } , Cmd.none )
                Err err ->
                    let
                        itemDeped = ItemDependencies 0 "" "" []
                    in
                    Debug.log ( Debug.toString err )
                    ( { model | itemDepended = itemDeped } , Cmd.none )


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo route model =
    case route of
        Nothing ->
            ( { model | route = route }, Cmd.none )
        Just HomeRoute ->
            ( { model | route = route }, Cmd.none )
        Just ItemsRoute ->
            ( { model | route = route }, getItems )
        Just (ItemRoute itemId) ->
            ( { model | route = route }, getItem itemId )
        Just ItemTypesRoute ->
            ( { model | route = route }, getItemTypes )



view : Model -> Browser.Document Msg
view model =
    case model.route of
        Nothing ->
            viewHomePage model
        Just HomeRoute ->
            viewHomePage model
        Just (ItemRoute _) ->
            viewItemPage model
        Just ItemsRoute ->
            viewItemsPage model
        Just ItemTypesRoute ->
            viewItemTypesPage model


viewHomePage : Model -> Browser.Document Msg
viewHomePage model =
    { title = "Izone | Items"
    , body =
        [ h1 [] [ text "Welcome Izone!" ]
        , a [ href "/#/" ] [ text "Home" ]
        , text " | "
        , a [ href "/#/items" ] [ text "Items" ]
        , text " | "
        , a [ href "/#/item_types" ] [ text "ItemTypes" ]
        , h2 [] [ text "Home!" ]
        ]
    }


viewItemsPage : Model -> Browser.Document Msg
viewItemsPage model =
    { title = "Izone | Items"
    , body =
        [ h1 [] [ text "Welcome Izone!" ]
        , a [ href "/#/" ] [ text "Home" ]
        , text " | "
        , a [ href "/#/items" ] [ text "Items" ]
        , text " | "
        , a [ href "/#/item_types" ] [ text "ItemTypes" ]
        , hr [] []
        , h2 [] [ text "Items" ]
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
         , td [] [ a [ href (String.concat ["/#/items/", String.fromInt item.id ]) ]
                     [ text item.name ]
                 ]
         , td [] [ text item.description ]
         ]
    )
    items


viewItemPage : Model -> Browser.Document Msg
viewItemPage model =
    { title = "Izone | Item"
    , body =
        [ h1 [] [ text "Welcome Izone!" ]
        , a [ href "/#/" ] [ text "Home" ]
        , text " | "
        , a [ href "/#/items" ] [ text "Items" ]
        , text " | "
        , a [ href "/#/item_types" ] [ text "ItemTypes" ]
        , hr [] []
        , h2 [] [ text "Item" ]
        , text (String.fromInt model.item.id)
        , text model.item.name
        , text model.item.description
        , hr [] []
        , h2 [] [ text "依存" ]
        , viewItemDependenciesTable model.itemDependencies.dependecies
        , hr [] []
        , h2 [] [ text "被依存" ]
        , viewItemDependenciesTable model.itemDepended.dependecies
        ]
    }

viewItemTypesPage : Model -> Browser.Document Msg
viewItemTypesPage model =
   { title = "Izone | Items"
   , body =
        [ h1 [] [ text "Welcome Izone!" ]
        , h2 [] [ text "ItemTypes!" ]
        , a [ href "/#/" ] [ text "Home" ]
        , text " | "
        , a [ href "/#/items" ] [ text "Items" ]
        , text " | "
        , a [ href "/#/item_types" ] [ text "ItemTypes" ]
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
         , a [ href (String.concat ["/#/item_types/", String.fromInt itemType.id ]) ]
             [ text itemType.name ]
         ]
    )
    itemTypes


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
         , td [] [ a [ href (String.concat ["/#/items/", String.fromInt dep.id ]) ]
                     [ text dep.name ]
                 ]
         , td [] [ text dep.description ]
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


getItem : Int -> Cmd Msg
getItem itemId =
    Http.get
        { url = String.concat [ "http://localhost:8080/items?id=", String.fromInt itemId]
        , expect = Http.expectJson GotItemMsg itemDecoder
        }


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
      { url = String.concat ["http://localhost:8080/item_dependencies?id=", String.fromInt(itemId) ]
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

getItemDepended : Int -> Cmd Msg
getItemDepended itemId =
    Http.get
      { url = String.concat ["http://localhost:8080/item_depended?id=", String.fromInt(itemId) ]
      , expect = Http.expectJson GotItemDependedMsg itemDependenciesDecoder
      }


subscriptions : Model -> Sub Msg
subscriptions model = Sub.none