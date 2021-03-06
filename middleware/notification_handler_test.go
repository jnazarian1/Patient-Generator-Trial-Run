package middleware

import (
	"net/http"
	"net/http/httptest"
	"os"

	"github.com/codegangsta/negroni"
	"github.com/gorilla/mux"
	"github.com/intervention-engine/fhir/models"
	"github.com/intervention-engine/fhir/server"
	"github.com/intervention-engine/ie/notifications"
	"github.com/pebbe/util"
	. "gopkg.in/check.v1"
	"gopkg.in/mgo.v2"
)

type NotificationHandlerSuite struct {
	Session                *mgo.Session
	Server                 *httptest.Server
	Handler                *NotificationHandler
	NotificationCollection *mgo.Collection
}

var _ = Suite(&NotificationHandlerSuite{})

func (n *NotificationHandlerSuite) SetUpSuite(c *C) {
	//Set up the database
	var err error
	n.Session, err = mgo.Dial("localhost")
	util.CheckErr(err)
	server.Database = n.Session.DB("ie-test")
	n.NotificationCollection = server.Database.C("communicationrequests")
	n.NotificationCollection.DropCollection()

	//register notification handler middleware
	n.Handler = &NotificationHandler{Registry: &notifications.NotificationDefinitionRegistry{}}
	mwConfig := map[string][]negroni.Handler{
		"EncounterCreate": []negroni.Handler{negroni.HandlerFunc(n.Handler.Handle)}}

	//set up routes and middleware
	router := mux.NewRouter()
	router.StrictSlash(true)
	router.KeepContext = true
	server.RegisterRoutes(router, mwConfig)

	//create test server
	n.Server = httptest.NewServer(router)
}

func (n *NotificationHandlerSuite) TearDownSuite(c *C) {
	n.Session.Close()
	n.Server.Close()
}

func (n *NotificationHandlerSuite) TearDownTest(c *C) {
	//clear the notification definition registry and the notification database
	n.Handler.Registry = &notifications.NotificationDefinitionRegistry{}
	n.NotificationCollection.DropCollection()
}

func (n *NotificationHandlerSuite) TestNotificationTriggers(c *C) {
	n.Handler.Registry.Register(new(PlannedEncounterNotificationDefinition))
	//load fixture
	data, err := os.Open("../fixtures/encounter-planned.json")
	defer data.Close()
	util.CheckErr(err)

	//post fixture
	client := &http.Client{}
	req, err := http.NewRequest("POST", n.Server.URL+"/Encounter", data)
	util.CheckErr(err)
	_, err = client.Do(req)

	//check for notification created
	query := n.NotificationCollection.Find(nil)

	//make sure there is only one
	count, _ := query.Count()
	c.Assert(count, Equals, 1)

	//make sure it is the right one
	result := models.CommunicationRequest{}
	query.One(&result)
	c.Assert(result.Id, Equals, "123")
	c.Assert(result.Subject.Reference, Equals, "http://intervention-engine.org/Patient/5540f2041cd4623133000001")
}

func (n *NotificationHandlerSuite) TestNotificationDoesNotTrigger(c *C) {
	n.Handler.Registry.Register(new(PlannedEncounterNotificationDefinition))

	//load fixture
	data, err := os.Open("../fixtures/encounter-office-visit.json")
	defer data.Close()
	util.CheckErr(err)

	//post fixture
	client := &http.Client{}
	req, err := http.NewRequest("POST", n.Server.URL+"/Encounter", data)
	util.CheckErr(err)
	_, err = client.Do(req)

	//check for no notification
	count, err := n.NotificationCollection.Count()
	c.Assert(count, Equals, 0)
}

//  Dummy notification definition for testing
type PlannedEncounterNotificationDefinition struct{}

func (def *PlannedEncounterNotificationDefinition) Name() string {
	return "Planned Encounter"
}
func (def *PlannedEncounterNotificationDefinition) Triggers(resource interface{}, action string) bool {
	enc, ok := resource.(*models.Encounter)
	return action == "create" && ok && enc.Status == "planned"
}
func (def *PlannedEncounterNotificationDefinition) GetNotification(resource interface{}, action string, baseURL string) *models.CommunicationRequest {
	if def.Triggers(resource, action) {
		enc := resource.(*models.Encounter)
		return &models.CommunicationRequest{Id: "123", Subject: enc.Subject}
	}
	return nil
}
