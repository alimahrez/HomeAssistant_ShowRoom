class CurtainCard extends HTMLElement {
    set hass(hass) {
      const _this = this;
      const entities = this.config.entities;

      //Init the card
      if (!this.card) {
        const card = document.createElement('ha-card');

        if (this.config.title) {
            card.header = this.config.title;
        }

        this.card = card;
        this.appendChild(card);

        let allcurtains = document.createElement('div');
        allcurtains.className = 'sc-curtains';
        entities.forEach(function(entity) {
          let entityId = entity;
          if (entity && entity.entity) {
              entityId = entity.entity;
          }

          let buttonsPosition = 'left';
          if (entity && entity.buttons_position) {
              buttonsPosition = entity.buttons_position.toLowerCase();
          }

          let titlePosition = 'top';
          if (entity && entity.title_position) {
              titlePosition = entity.title_position.toLowerCase();
          }

          let invertPercentage = false;
          if (entity && entity.invert_percentage) {
            invertPercentage = entity.invert_percentage;
          }

          let curtain = document.createElement('div');

          curtain.className = 'sc-curtain';
          curtain.dataset.curtain = entityId;
          curtain.innerHTML = `
            <div class="sc-curtain-top" ` + (titlePosition == 'bottom' ? 'style="display:none;"' : '') + `>
              <div class="sc-curtain-label">

              </div>
              <div class="sc-curtain-position">

              </div>
            </div>
            <div class="sc-curtain-middle" style="flex-direction: ` + (buttonsPosition == 'right' ? 'row-reverse': 'row') + `;">
              <div class="sc-curtain-buttons">
                <ha-icon-button icon="mdi:arrow-split-vertical" class="sc-curtain-button" data-command="right"></ha-icon-button><br>
                <ha-icon-button icon="mdi:stop" class="sc-curtain-button" data-command="stop"></ha-icon-button><br>
                <ha-icon-button icon="mdi:arrow-collapse-horizontal" class="sc-curtain-button" data-command="left"></ha-icon-button>
              </div>
              <div class="sc-curtain-selector">
                <div class="sc-curtain-selector-picture">
                  <div class="sc-curtain-selector-slide"></div>
                  <div class="sc-curtain-selector-slide1"></div>
                  <div class="sc-curtain-selector-picker"></div>
                </div>
              </div>
            </div>
            <div class="sc-curtain-bottom" ` + (titlePosition != 'bottom' ? 'style="display:none;"' : '') + `>
              <div class="sc-curtain-label">

              </div>
              <div class="sc-curtain-position">

              </div>
            </div>
          `;

          let picture = curtain.querySelector('.sc-curtain-selector-picture');
          let slide = curtain.querySelector('.sc-curtain-selector-slide');
          let slide1 = curtain.querySelector('.sc-curtain-selector-slide1');
          let picker = curtain.querySelector('.sc-curtain-selector-picker');

          let mouseDown = function(event) {
              if (event.cancelable) {
                //Disable default drag event
                event.preventDefault();
              }

              _this.isUpdating = true;

              document.addEventListener('mousemove', mouseMove);
              document.addEventListener('touchmove', mouseMove);
              document.addEventListener('pointermove', mouseMove);

              document.addEventListener('mouseup', mouseUp);
              document.addEventListener('touchend', mouseUp);
              document.addEventListener('pointerup', mouseUp);
          };

          let mouseMove = function(event) {
            let newPosition = event.pageX - _this.getPictureRight(picture);
            _this.setPickerPosition(newPosition, picker, slide, slide1);
          };

          let mouseUp = function(event) {
            _this.isUpdating = false;

            let newPosition = event.pageX - _this.getPictureRight(picture);

            if (newPosition < _this.minPosition)
              newPosition = _this.minPosition;

            if (newPosition > _this.maxPosition)
              newPosition = _this.maxPosition;

            let percentagePosition = (newPosition - _this.minPosition) * 100 / (_this.maxPosition - _this.minPosition);

            if (invertPercentage) {
              _this.updatecurtainPosition(hass, entityId, percentagePosition);
            } else {
              _this.updatecurtainPosition(hass, entityId, 100 - percentagePosition);
            }

            document.removeEventListener('mousemove', mouseMove);
            document.removeEventListener('touchmove', mouseMove);
            document.removeEventListener('pointermove', mouseMove);

            document.removeEventListener('mouseup', mouseUp);
            document.removeEventListener('touchend', mouseUp);
            document.removeEventListener('pointerup', mouseUp);
          };

          //Manage slider update
          picker.addEventListener('mousedown', mouseDown);
          picker.addEventListener('touchstart', mouseDown);
          picker.addEventListener('pointerdown', mouseDown);

          //Manage click on buttons
          curtain.querySelectorAll('.sc-curtain-button').forEach(function (button) {
              button.onclick = function () {
                  const command = this.dataset.command;

                  let service = '';

                  switch (command) {
                    case 'right':
                        service = 'open_cover';
                        break;

                    case 'left':
                        service = 'close_cover';
                        break;

                    case 'stop':
                        service = 'stop_cover';
                        break;
                  }

                  hass.callService('cover', service, {
                    entity_id: entityId
                  });
              };
          });

          allcurtains.appendChild(curtain);
        });


        const style = document.createElement('style');
        style.textContent = `
          .sc-curtains { padding: 16px; }
            .sc-curtain { margin-top: 1rem; overflow: hidden; }
            .sc-curtain:first-child { margin-top: 0; }
            .sc-curtain-middle { display: flex; width: 210px; margin: auto; }
              .sc-curtain-buttons {  flex: 1; text-align: center; margin-top: 0.4rem; }
              .sc-curtain-selector { flex: 1; }
                .sc-curtain-selector-picture { position: relative; margin: auto; background-size: cover; min-height: 150px; max-height: 100%; width: 165px; }
                  .sc-curtain-selector-picture { background-image: url(/local/window-3.png);}
                                .sc-curtain-selector-slide { position: absolute; width: 100%; right: 25px  ; height: 100%; }
                  .sc-curtain-selector-slide { background-image:  url(/local/local.png); }
                                .sc-curtain-selector-slide1 { position: absolute; width: 100%; left: 28px; height: 100%; }
                  .sc-curtain-selector-slide1 { background-image:  url(/local/local.png); }
                .sc-curtain-selector-picker { position: absolute; right: 50px ;  width: 25px; cursor: pointer; height: 100%; background-repeat: no-repeat; }
                  .sc-curtain-selector-picker { background-image: url(/local/nnn.png); }
            .sc-curtain-top { text-align: center; margin-bottom: 1rem; }
            .sc-curtain-bottom { text-align: center; margin-top: 1rem; }
              .sc-curtain-label { display: inline-block; font-size: 20px; vertical-align: middle; }
              .sc-curtain-position { display: inline-block; vertical-align: middle; padding: 0 0px; margin-right: 1rem; border-radius: 2px; background-color: var(--secondary-background-color); }
        `;

        this.card.appendChild(allcurtains);
        this.appendChild(style);
      }

      //Update the curtains UI
      entities.forEach(function(entity) {
        let entityId = entity;
        if (entity && entity.entity) {
          entityId = entity.entity;
        }

        let invertPercentage = false;
        if (entity && entity.invert_percentage) {
          invertPercentage = entity.invert_percentage;
        }

        const curtain = _this.card.querySelector('div[data-curtain="' + entityId +'"]');
        const slide = curtain.querySelector('.sc-curtain-selector-slide');
        const slide1 = curtain.querySelector('.sc-curtain-selector-slide1');
        const picker = curtain.querySelector('.sc-curtain-selector-picker');

        const state = hass.states[entityId];
        const friendlyName = (entity && entity.name) ? entity.name : state ? state.attributes.friendly_name : 'unknown';
        const currentPosition = state ? state.attributes.current_position : 'unknown';

        curtain.querySelectorAll('.sc-curtain-label').forEach(function(curtainLabel) {
            curtainLabel.innerHTML = friendlyName;
        })

        if (!_this.isUpdating) {
          curtain.querySelectorAll('.sc-curtain-position').forEach(function (curtainPosition) {
            curtainPosition.innerHTML = currentPosition + '%';
          })

          if (invertPercentage) {
            _this.setPickerPositionPercentage(currentPosition, picker, slide ,slide1);
          } else {
            _this.setPickerPositionPercentage(100 - currentPosition, picker, slide, slide1);
          }
        }
      });
    }

    getPictureRight(picture) {
        let pictureBox = picture.getBoundingClientRect();
        let body = document.body;
        let docEl = document.documentElement;

        let scrollLeft =  window.pageXOffset || -docEl.scrollLeft || body.scrollLeft ;

        let clientLeft = docEl.clientLeft || body.clientLeft || 0;

        let pictureLeft  = pictureBox.left + scrollLeft - clientLeft;

        return pictureLeft;
    }

    setPickerPositionPercentage(position, picker, slide, slide1) {
      let realPosition = (this.maxPosition - this.minPosition) * position / 100 + this.minPosition;

      this.setPickerPosition(realPosition, picker, slide,slide1);
    }

    setPickerPosition(position, picker, slide, slide1) {
      if (position < this.minPosition)
        position = this.minPosition;

      if (position > this.maxPosition)
        position = this.maxPosition;

      picker.style.left = ( position / 2 )  + 'px';
      slide.style.width = (((position - this.minPosition ) / 2 ) + 5)+ 'px';
      slide1.style.width = (((position - this.minPosition) /2 ) + 5 ) + 'px';
    }

    updatecurtainPosition(hass, entityId, position) {
      let curtainPosition = Math.round(position);

      hass.callService('cover', 'set_cover_position', {
        entity_id: entityId,
        position: curtainPosition
      });
    }

    setConfig(config) {
      if (!config.entities) {
        throw new Error('You need to define entities');
      }

      this.config = config;
      this.maxPosition = 140;
      this.minPosition = 35;
      this.isUpdating = false;
    }

    // The height of your card. Home Assistant uses this to automatically
    // distribute all cards over the available columns.
    getCardSize() {
      return this.config.entities.length + 1;
    }
  }

  customElements.define("curtainha-card", CurtainCard);