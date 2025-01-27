<link rel="stylesheet" href="/assets/css/main/events.css">


<script src="/assets/js/directives/hg-tabs.js"></script>
<script src="/assets/js/directives/hg-sortable.js"></script>
<script src="/assets/js/directives/hg-expand.js"></script>
<script src="/assets/js/directives/hg-modal.js"></script>
<script src="/assets/js/directives/hg-formdata.js"></script>
<script src="/assets/js/directives/hg-filehandler.js"></script>
<script src="/assets/js/main/session.js"></script>
<script src="/assets/js/main/events.js"></script>


<main class="pagebody" x-data="app" x-session>

  <!--- Error div --->
  <!--- x-cloak x-transition  x-show="shows" --->
  <div class="hg-error"
    x-cloak 
    x-transition 
    x-show="shows"
    x-data="{ shows: false, message: 'An error has occurred!' }"
    @error.window='shows = true'
    @completion.window='shows = false'
  >
    <span x-text="message"></span>
  </div>


  <!--- Send a notification --->
  <template
    x-modal='notification'
    x-if='$modal?.notification?.opened'
  >
    <div class="hg-modal">
      <div class="hg-modal-content">
        <div class="hg-modal-content-header">
          <div class="hg-modal-title">Send Notification?</div>
          <div class="hg-modal-close" @click="$modal.notification.cancel">&#10006;</div>
        </div>
        <div class="hg-modal-content-body" x-show='$store.sending == 1'>
          Please confirm that you would like to send a notification for 
          <b x-text="$modal.notification.data.eventname"></b>
        </div>
        <div class="hg-modal-content-body" x-show='$store.sending == 2'>
          <div class="loading">
            <div>Sending...</div>
            <div></div>
          </div>
        </div>
        <div class="hg-modal-content-body" x-show='$store.sending == 3'>
          Done!
          <p>If you are part of this group and do not see this notiifcation in your email inbox, please check your spam folder.  Thanks!</p>
        </div>
        <div class="hg-modal-content-body" x-show='$store.sending == 4'>
          Uh oh!
          <p>It looks like there was an error sending out this notification.  Please try again later.</p>
        </div>
        <div class="hg-modal-content-footer">
          <button class="action" @click="$modal.notification.cancel" x-show='$store.sending == 1'>Cancel</button>
          <div x-show="$store.sending > 1"></div> 
          <button class="action" @click="$store.sending = 2; $store.sending = await sendNotification( $modal.notification.data ) ? 3 : 4" x-show='$store.sending < 3'>Send</button>
          <button class="action" @click="$modal.notification.close" x-show='$store.sending >= 3'>OK</button>
        </div>
      </div>
    </div>
  </template>


  <!--- Remove events here. --->
  <template 
    x-modal='remove'
    x-if='$modal?.remove?.opened'
    x-modal.preclose='remove( $modal.remove.data )'
  >
    <div class="hg-modal">
      <div class="hg-modal-content">
        <div class="hg-modal-content-header">
          <div class="hg-modal-title">Remove Event</div>
          <div class="hg-modal-close" @click="$modal.remove.cancel">&#10006;</div>
        </div>
        <div class="hg-modal-content-body">
          Remove event titled <b><span x-text="$modal.remove.data.eventname"></span></b>?
          <div x-show="$modal.remove.data.apptcount > 0">
            <p x-text="`This event currently has appointments scheduled and all will be deleted if it is cancelled.`"></p>
          </div>
          <div class="hg-modal-content-footer">
            <button class="action" @click="$modal.remove.cancel">Cancel </button>
            <button class="action" @click="$modal.remove.close">OK</button>
          </div> 
        </div>
      </div>
    </div>
  </template>


  <!--- Add new events here. --->
  <template 
    x-modal='view'
    x-if='$modal?.view?.opened'
    x-modal.preclose="$modal.view.data.edit ? update( $modal.view.data ) : submit( $modal.view.data )"
  >

    <div class="hg-modal" x-data="formdata( $modal.view.data )">
      <div class="hg-modal-content">

        <div class="hg-modal-content-header">
          <div class="hg-modal-title" x-text="windowTitle"></div>
          <div class="hg-modal-close" @click="$modal.view.cancel">&#10006;</div>
        </div>

        <div class="hg-modal-content-body">
        <template x-if="page == 1">
          <form x-formdata @submit.prevent="nextPage( $formdata )">
            <div class="hg-modal-informational-label">
              <label>Event Details</label>

              <div>
                <label for="eventname" title="Specify a name for this event">Event Name*</label>
                <input type="text" name="eventname" x-model="eventname" required>
              </div>

              <div>
                <label for="typeid" title="Specify the Type of Event This is">Event Type*</label>
                <select name="typeid" x-model="typeid" required>
                  <option value="">Select an Event Type</option>
                <template x-for="d of types()">
                  <option :value="d.id" :selected="d.id == typeid">
                    <span x-text="d.type"></span>
                  </option>
                </template> 
                </select>
              </div>

              <div class="hg-modal-two-column">
                <div>
                  <label for="groupid" title="Specify the group administering this event">Group*</label>
                  <select name="groupid" x-model="groupid" required>
                    <option value="">Select a Group</option>
                  <template x-for="d of groups()">
                    <option :value="d.id" :selected="d.id == groupid">
                      (<span x-text="d.pargrp"></span>) <span x-text="d.groupname"></span>
                    </option>
                  </template> 
                  </select>
                </div>

                <div>
                  <label for="locationid" title="Specify the event location">Event Location*</label>
                  <button class="action" @click="console.log( 'Create a new location' )"
                    x-show="groupid != -1 && !locations( groupid ).length">
                    Create New Location
                  </button>

                  <select name="locationid" x-model="locationid" x-show="groupid != -1 && locations( groupid ).length" :disabled="groupid == -1">
                    <option value="">Select a Location</option>
                  <template x-for="d of locations( groupid )">
                    <option :value="d.id" :selected="d.id == locationid">
                      <span x-text="d.locname"></span>
                    </option>
                  </template> 
                  </select>

                  <div x-show='groupid == -1' style='width:100%; height: 30px;'>
                  No location selected
                  </div>

                </div>
              </div>

              <div>
                <label for="groupid" title="Please describe this event in less than 256 characters.">Description</label>
                <textarea name="description" x-model="description"></textarea>
              </div>
            </div> <!--- hg-modal-informational-label --->


            <div class="hg-modal-content-footer">
              <div></div>
              <input class="action" type="submit" value="Next">
            </div>
          </form> 
        </template>

        <template x-if="page == 2">
          <form x-formdata @submit.prevent="nextPage( $formdata )">
            <div class="hg-modal-informational-label">
              <label>Date, Time and Recurrence Details</label>

              <div class="hg-modal-two-column">
                <div>
                  <label for="startdate" title="Specify the event's start date"
                    x-text=" recurs ? 'Event Start Date*' : 'Event Date*' ">
                  </label>
                  <input type="date" name="startdate" :min="mineventdate" x-model="startdate" required>
                </div>
                <div style="display:flex; flex-direction: row; gap: 10px;">
                  <div>
                    <label for="starttime" title="What time does this event start?">From*</label>
                    <input type="time" name="starttime" step="0:15" min="06:00" max="18:00" 
                      x-model='starttime' required>
                  </div>
                  <div>
                    <label for="endtime" title="What time does this event end?">To*</label>
                    <input type="time" name="endtime" step="0:15" min="06:00" max="18:00" 
                      x-model='endtime' required>
                  </div>
                </div>
              </div>

              <div class="hg-checkbox">
                <label for="recurs" title="Specify whether or not this event recurs">
                  Is this a recurring or repeating event?
                </label>
                <input type="checkbox" name="recurs" :checked="recurs" x-model="recurs">
              </div>

              <template x-if="recurs"> 
                <div class="hg-modal-two-column">
                  <div>
                    <label for="recurrenceinterval" title="Specify this event's recurrence interval.">Occurs</label>
                    <select name="recurrenceinterval" x-model="recurrenceinterval">
                      <option value=''>Select Recurrence</option>
                    <template x-for="d of recurrence.intervals()">
                      <option :value="d.id" :selected="d.id == recurrenceinterval">
                        <span x-text="d.text"></span>
                      </option>
                    </template>
                    </select>
                  </div>

                  <div> 
                    <label for="enddate" title="Specify the event's end date">Until</label>
                    <input type="date" :min="startdate" name="enddate" x-model="enddate" :required="recurs">
                  </div> 
                </div> <!--- "hg-modal-two-column" --->

                <div class="hg-modal-two-column" x-show="fetchIntervalDays( recurrenceinterval )" x-transition>
                  <label for="recurrencedays">On</label>
                  <table name="recurrencedays">
                    <thead>
                    <template x-for="d of recurrence.days()">
                      <th x-text="d.text"></th>
                    </template>
                    </thead>
                    <tbody>
                      <tr>
                      <template x-for="d of recurrence.days">
                        <td><input type="checkbox" :name="`day_${d.id}`"></td>
                      </template>
                      </td>
                    </tbody>
                  </table>
                </div>
              </template> <!--- x-show="eventrecurs" --->
            </div>


            <div class="hg-modal-informational-label">
              <label>Appointment Booking Details</label>

              <div class="hg-modal-two-column">
              <div>
                <label for="portaldate" title="Specify the first day that the event should appear in the Member Portal">
                  Portal Appearance Date*
                </label>
                <input type="date" name="portaldate" :min="minportaldate" x-model="portaldate" required>
              </div>

              <div style="display:flex; flex-direction: row; gap: 10px;">
                <div>
                  <label for="slottime" title="Specify the approximate length of each scheduled appointment">Appointment Length*</label>
                  <select name="slottime" x-model="slottime" required>
                    <option value=''>Select a Time Slot</option>
                    <template x-for="d of timeslots()">
                    <option :value="d" :selected="d == slottime">
                      <span x-text="d"></span> minutes
                    </option>
                    </template> 
                  </select>
                </div>
                <div>
                  <label for="aptsperslot" 
                  title="Specify the number of appointments you expect to manage per slot">
                    Appts per Slot
                  </label>
                  <input type="number" name="aptsperslot" value="1" min="1" max="1000" x-model="aptsperslot" required>
                </div>
              </div>
              
              </div>

              <div class="hg-checkbox">
                <label for="eventblocks">Will there be any times that you cannot accept appointments?</label>
                <input type="checkbox" name="blocks" :checked="blocked" x-model="blocked">
              </div>

              <template x-if="blocked">
                <div class="hg-modal-two-column">
                  <div>
                    <label for="blockstart" title="Specify a time When no appointments can be taken">Block Start</label>
                    <input type="time" name="blockstart" :min="starttime" :max="endtime" x-model="blockstart" :required="blocked">
                  </div>
                  <div>
                    <label for="blockend" title="Specify a time When appointments can resume">Block End</label>
                    <input type="time" name="blockend" :min="starttime" :max="endtime" x-model="blockend" :required="blocked">
                  </div>
                </div> <!--- class="hg-modal-two-column" --->
              </template>
            </div> <!--- class="hg-modal-informational-label" --->
          </div> 




            <div class="hg-modal-content-footer">
              <button class="action" @click="prevPage()">Back</button>
              <input class="action" type="submit" value="Next">
            </div>
          </form> <!--- (page 2 ) --->
        </template>

        <template x-if="page == 3">
          <form x-formdata @submit.prevent="merge( data.event, $formdata ) && $modal.view.close"> 

            <div class="hg-modal-informational-label">
              <label>Notification Details</label>
              <div class="hg-checkbox">
                <label for="reminder" title="Specify whether or not you want to receive an event reminder">
                  Would you like a reminder notification for this event?</label>
                <input type="checkbox" name="reminderwanted" :checked="reminderwanted" x-model="reminderwanted">
              </div>
              <template x-if="reminderwanted"> 
                <div>
                  <div class="hg-modal-two-column">
                    <div>
                      <label for="reminddaysbefore" 
                        title="Specify a time to send the event reminder">
                        Send Notification at*
                      </label>
                      <select name="reminddaysbefore" x-model="reminddaysbefore" :required="reminderwanted">
                        <option value="">Select a Time</option>
                        <template x-for="d of reminder.intervals()">
                        <option :value='d.id' :selected="d.id == reminddaysbefore">
                          <span x-text="d.classifier"></span>
                        </option>
                        </template>
                      </select>
                    </div>
                    <div>
                      <label>Send Email From*</label>
                      <input type="text" name="senderemail" x-model="senderemail" :required="reminderwanted">
                    </div>
                  </div> <!--- 2 column --->
                  <div>
                    <label>Send Email To*</label>
                    <input type="text" name="noticeemail" x-model="noticeemail" :required="reminderwanted">
                  </div>
                  <div>
                    <label>Upload an Email Banner</label>
                    <div class="hg-modal-two-column">
                      <div>
                        Choose a custom banner to send with your email notification.
                        <input type="file" name="uibanner" style="width: 150px; height: 100%;" x-filesink>
                        <input type="hidden" name="noticebanner" :value="$filedata?.url">
                      </div>
                      <div style="padding: 10px; background:#ccc; height: 100%; border:1px solid white; display: inline-block;">
                        <img :src="bannerplaceholder( $filedata?.url )">
                      </div>
                    </div>
                  </div>
                  <div>
                    <label for="emailnotes" title="Specify text for the reminder email">
                      Special Note for Reminder Emails</label>
                    <textarea name="emailnotes" x-model="emailnotes"></textarea>
                  </div>
                </div>
              </template>
            </div>

            <div class="hg-modal-informational-label">
              <label>Additional Details</label>
              <div class="hg-checkbox">
                <label for="instructionswanted" title="Specify any additional instructions">
                  Are there any additional comments or instructions you would like added to this event?</label>
                <input type="checkbox" name="instructionswanted" :checked="instructionswanted" x-model="instructionswanted">
              </div>

              <div x-show="instructionswanted">
                <label for="instructions" title="Specify any additional event instructions">
                  Comments/Instructions</label>
                <textarea name="instructions" x-model="instructions"></textarea>
              </div>
            </div>

            <div class="hg-modal-content-footer">
              <button class="action" @click="prevPage()">Back</button>
              <input class="action" type="submit" value="Add Event">
            </div>
          </form> <!--- (page 3 ) --->
        </template>

        </div> <!--- hg-modal-content-body --->
      </div> <!--- hg-modal-content --->
    </div> <!--- hg-modal ---> 
  </template>


  <!--- Our loading screen --->
  <template x-if="$store.loading">
    <div class="loading">
      <div>Loading...</div>
      <div></div>
    </div>
  </template>


  <!--- Our actual screens --->
  <template x-if="!$store.loading" x-transition>
    <div class="actual-content">

      <header class="app-mgmt" x-show='$session.hgadmin'>
        <h1>Events</h1>
        <button class="action" @click="$modal.view.data = {}; $modal.view.open()">Add a New Event</button>
      </header>

      <!--- Viewing and Editing Actual Events Takes Place Here --->
      <div class="hg-card" x-show="!$store.loading">
        <div class="tabs-container" x-tabs>
          <ul class="tabs">
            <li class="tab active" data-tab="tab-1" x-tab-selector>
              Active Events (<span x-text='data.active.length'></span>)
            </li>
            <li class="tab" data-tab="tab-2" x-tab-selector>
              Past Events (<span x-text='data.inactive.length'></span>)
            </li>
          </ul>

          <div id="tab-1" class="content active" x-tab>
            <div class="card-body scrollable-card">

            <template x-if='!data.active.length'>
              <div>No current events found.</div>
            </template>

            <template x-if='data.active.length'> 
            <div x-data='data.active' x-sortable='{ class: "-sorted" }' x-init='addTestIds( data.active )'>
              <div class="hg-grid-container grid-header--hgBlue grid--col-6-auto grid--no-border">
                <div class="grid-header">
                  Event Name & Location <i class="fas fa-angle-down" x-sort='eventname'></i>
                </div>
                <div class="grid-header">
                  Group <i class="fas fa-angle-down" x-sort='pargrp'></i>
                </div>
                <div class="grid-header">
                  Type <i class="fas fa-angle-down" x-sort='eventtype'></i>
                </div>
                <div class="grid-header">
                  Date <i class="fas fa-angle-down" x-sort='eventdate'></i>
                </div>
                <div class="grid-header">
                  Recurs? 
                  <!--- <i class="fas fa-angle-down" x-sort='recurs'></i> --->
                </div>
                <div class="grid-header">
                </div>
                <template x-for='d of data.active'>
                  <div
                    x-transition
                    x-show='d.relatedid < 1 || $expand.id == d.relatedid'
                    :class="[ 'grid-row', d.relatedid < 1 ? 'parent' : 'child', d.relatedid != $expand.id ? 'menu' : '' ]">
                    <div class="grid-item" x-text="d.eventname"></div>
                    <div class="grid-item" x-text="d.pargrp"></div>
                    <div class="grid-item" x-text="d.eventtype"></div>
                    <div class="grid-item" x-text="d.eventdate"></div>
                    <div class="grid-item" x-text="d.recurs"></div>
                    <div class="grid-item" :data-testid="`eventid-${d.index}`" :data-eventid="d.eventid">
                      <template x-if='$session.hgadmin'> 
                        <div x-show='$session.hgadmin && d.relatedid == -1 && $expand.id > -1' style='font-size: 8px !important;'>
                          <a @click="d.all = true; $modal.view.open( d )" x-show='$session.hgadmin'>Edit All in Series</a><br>
                          <a @click="d.all = true; $modal.remove.open( d )" x-show='$session.hgadmin'>Delete All in Series</a>
                        </div>
                      </template> 
                      <div class="hg-dropdown-activate" 
                        style='display: flex; flex-direction: row; align-items: center;'
                        x-expand='$expand.id = $expand.id == -1 ? d.eventid : -1'
                        x-show="d.relatedid < 0"
                      >
                        <i class="fas fa-angle-down tx-10"></i>
                      </div>
                      <div x-show="d.relatedid == 0">
                        <template x-if="$session.hgadmin && d.notificationid">
                          <i @click="$modal.notification.open(d)" class="fas fa-share-square tx-10" title="Send Notification" ></i> 
                        </template>
                        <i @click="d.edit = true; $modal.view.open( d )" title="Edit Event" class="fas fa-pencil tx-10" x-show='$session.hgadmin'></i>
                        <i @click="$modal.remove.open( d )" title="Delete Event" class="fas fa-trash tx-10" x-show='$session.hgadmin'></i>
                      </div>
                      <div x-show="$expand.id > 0 && d.relatedid > 0">
                        <template x-if="d.notificationid">
                          <i @click="sendNotification(d)" class="fas fa-share-square tx-10" title="Send Notification" ></i>
                        </template>
                        <i @click="d.edit = true; $modal.view.open( d )" title="Edit Event" class="fas fa-pencil tx-10" x-show='$session.hgadmin'></i>
                        <i @click="$modal.remove.open( d )" title="Delete Event" class="fas fa-trash tx-10" x-show='$session.hgadmin'></i>
                      </div>
                      <template x-if='!$session.hgadmin'> 
                        <a @click="console.log( 'more info' )">More Info</a><br>
                      </template> 
                    </div>
                  </div>
                </template> 
              </div> <!--- class="hg-grid-container" --->
            </div>
            </template> <!--- template x-if='data.active.length' --->
            </div> <!--- class="card-body scrollable-card" --->
          </div><!--- id="tab-1" class="tab-content active" --->

          <div id="tab-2" class="content" x-tab>
            <div class="card-body scrollable-card">
            <template x-if='!data.inactive.length'>
              <div>No past events found.</div>
            </template>

            <template x-if='data.inactive.length'> 
            <div x-data='data.inactive' x-sortable='{ class: "-sorted" }'>
              <div class="hg-grid-container grid-header--hgBlue grid--col-5-auto grid--no-border past">
                <div class="grid-header">
                  Event Name & Location <i class="fas fa-angle-down" x-sort='eventname'></i>
                </div>
                <div class="grid-header">
                  Group <i class="fas fa-angle-down" x-sort='pargrp'></i>
                </div>
                <div class="grid-header">
                  Type <i class="fas fa-angle-down" x-sort='eventtype'></i>
                </div>
                <div class="grid-header">
                  Date <i class="fas fa-angle-down" x-sort='eventdate'></i>
                </div>
                <div class="grid-header">
                </div>
                <template x-for='d of data.inactive'>
                  <div
                    x-transition
                    x-show='d.relatedid < 1 || $expand.id == d.relatedid'
                    :class="[ 
                      'grid-row', 
                      d.relatedid < 1 ? 'parent' : 'child', 
                      d.relatedid != $expand.id ? 'menu' : '' 
                    ]">

                    <div class="grid-item" x-text="d.eventname"></div>
                    <div class="grid-item" x-text="d.pargrp"></div>
                    <div class="grid-item" x-text="d.eventtype"></div>
                    <div class="grid-item" x-text="d.eventdate"></div>
                    <div class="grid-item">
                      <div class="hg-dropdown-activate" 
                        x-expand='$expand.id = $expand.id == -1 ? d.eventid : -1'
                        x-show="d.relatedid < 0">
                        <i class="fas fa-angle-down tx-16"></i>
                      </div>
                      <div x-show="d.relatedid == 0">
                        <i @click="$modal.view.open( d )" title="View Event Details" class="fas fa-info tx-10"></i>
                      </div>
                      <div x-show="$expand.id > 0 && d.relatedid > 0">
                        <i @click="$modal.view.open( d )" title="View Event Details" class="fas fa-info tx-10"></i>
                      </div>
                    </div>
                  </div>
                </template> 
              </div> <!--- class="hg-grid-container" --->
            </div>
            </template> <!--- template x-if='data.inactive.length' --->

            </div>
          </div><!--- id="tab-2" --->
        </div> <!--- tabs-container --->
      </div> <!--- hg-card --->

    </div>
  </template>

</main>
