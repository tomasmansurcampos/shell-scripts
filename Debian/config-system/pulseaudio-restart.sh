#!/bin/bash
pulseaudio_restart_()
{
	pulseaudio -k
	pulseaudio -D
	pulseaudio --start
}
pulseaudio_restart_
