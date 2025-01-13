module Components.AddWidgetForm exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra
import Models.DataSource exposing (..)
import Models.Widgets exposing (..)


type alias Model =
    { widget : Widget
    , selectedTable : Table
    , tables : List Table
    , isWidgetTypeSelected : Bool
    }


type Msg
    = TableSelected String
    | WidgetTypeSelected String
    | ColumnToggled String
    | Cancel
    | AddNewWidget


init : List Table -> Model
init tables =
    { widget = emptyWidget ""
    , selectedTable = Table "" []
    , tables = tables
    , isWidgetTypeSelected = False
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Cancel ->
            clearForm model

        TableSelected tableName ->
            updateTableSelection tableName model

        ColumnToggled columnName ->
            toggleColumn columnName model

        WidgetTypeSelected widgetType ->
            let
                selectedTable =
                    List.head model.tables |> Maybe.withDefault (Table "" [])
            in
            { model | widget = emptyWidget widgetType, isWidgetTypeSelected = True, selectedTable = selectedTable }

        AddNewWidget ->
            model


updateTableSelection : String -> Model -> Model
updateTableSelection tableName model =
    let
        selectedTable =
            List.Extra.find (\table -> table.name == tableName) model.tables

        updatedWidget =
            case model.widget of
                Pie data ->
                    Pie { data | table = tableName }

                Histogram data ->
                    Histogram { data | table = tableName }
    in
    case selectedTable of
        Just table ->
            { model | selectedTable = table, widget = updatedWidget }

        Nothing ->
            model


toggleColumn : String -> Model -> Model
toggleColumn columnName model =
    let
        updatedWidget =
            case model.widget of
                Pie data ->
                    Pie { data | data_column = columnName }

                Histogram data ->
                    Histogram { data | data_column = columnName }
    in
    { model | widget = updatedWidget }


clearForm : Model -> Model
clearForm model =
    { model | widget = emptyWidget "", selectedTable = Table "" [], isWidgetTypeSelected = False }


emptyWidget : String -> Widget
emptyWidget widgetType =
    case widgetType of
        "PieChart" ->
            Pie { widget_id = 0, title = "", table = "", data_column = "", data = [] }

        "Histogram" ->
            Histogram { widget_id = 0, title = "", table = "", data_column = "", data = [] }

        _ ->
            Pie { widget_id = 0, title = "", table = "", data_column = "", data = [] }


view : Model -> Html Msg
view model =
    div [ class "add-widget form" ]
        [ h3 [] [ text "Add Widget" ]
        , div [ class "form-content" ]
            [ div [ class "form-group" ]
                [ select
                    [ class "table-dropdown", onInput WidgetTypeSelected ]
                    [ option [ value "PieChart" ] [ text "Pie Chart" ]
                    , option [ value "Histogram" ] [ text "Histogram" ]
                    ]
                ]
            , if model.isWidgetTypeSelected then
                div [ class "form-group" ]
                    [ select
                        [ class "table-dropdown", onInput TableSelected ]
                        (List.map (\table -> option [ value table.name ] [ text table.name ]) model.tables)
                    , div [] [ text "Select columns:" ]
                    , viewTableColumns model.selectedTable
                    ]

              else
                text ""
            , button [ class "add-widget-button", onClick AddNewWidget ] [ text "Add Widget" ]
            , button [ class "cancel-button", onClick Cancel ] [ text "Cancel" ]
            ]
        ]


viewTableColumns : Table -> Html Msg
viewTableColumns table =
    div []
        [ select [ class "table-dropdown", onInput ColumnToggled ]
            (List.map (\col -> option [ value col.name ] [ text col.name ]) table.columns)
        ]