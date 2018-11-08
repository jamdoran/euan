
#  Ask the user some questions
name    = input('What is your name user? ')
age     = input('How old are you user? ' )
team    = input('What is your favourite football team? ')
pokemon = input ('What is your favourite Pokemon? ')

# Print out the users answers
print ()
print ('Hello '+ name)
print ('Aged ' + age)
print ('Ok')
print (pokemon + ' is a good choice, I like it too! ')
print ()

# Check if the team is Chelsea
# But convert to lower case letters before we check
if team.lower() == 'chelsea':
    print ('Chelsea is great')
else:
    print ('Your team is rubbish')


# Print a blank line
print()

# Say Goodbye
print ('Goodbye, ' + name)


# All Done
