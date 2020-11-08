#!/bin/bash

echo -e  "\e[31mDeleting network namespace 'nns-dtn-1'..."
ip netns delete nns-dtn-1
echo -e  "\e[31mDeleting network namespace 'nns-dtn-2'..."
ip netns delete nns-dtn-2
echo -e  "\e[31mDONE"

