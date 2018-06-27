//
//  SetThemeChooserViewController.swift
//  
//
//  Created by Darren Wilson on 25/06/2018.
//

import UIKit

class SetThemeChooserViewController: UIViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func awakeFromNib() {
        splitViewController?.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier,
                identifier == "Theme Selected",
                let setViewController = segue.destination as? SetGameViewController
        {
            setViewController.theme = lastUserSelectedTheme!
            lastSeguedToSetGameViewController = setViewController
        }
    }
    
    var splitViewDetailSetGameViewController: SetGameViewController? {
        return splitViewController?.viewControllers.last as? SetGameViewController
    }
    
    var lastSeguedToSetGameViewController: SetGameViewController?
    
    var setGameViewController: SetGameViewController? {
        if let setViewController = splitViewDetailSetGameViewController {
            return setViewController
        } else if let lastSegued = lastSeguedToSetGameViewController {
            navigationController?.pushViewController(lastSegued, animated: true)
            return lastSegued
        } else {
            return nil
        }
    }
    
    var lastUserSelectedTheme: Theme?
    
    @IBAction func normalButtonPressed(_ sender: UIButton) {
        lastUserSelectedTheme = .normal
        changeThemeTo(new: lastUserSelectedTheme!)
    }
    
    @IBAction func SpookyButtonPressed(_ sender: UIButton) {
        lastUserSelectedTheme = .spooky
        changeThemeTo(new: lastUserSelectedTheme!)
    }
    
    func changeThemeTo(new theme: Theme) {
        if let viewControllerToChangeThemeOf = setGameViewController {
            viewControllerToChangeThemeOf.theme = theme
        } else {
            performSegue(withIdentifier: "Theme Selected", sender: nil)
        }
    }
    
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController
        ) -> Bool
    {
        if lastUserSelectedTheme == nil {
            return true
        }
        return false
    }
}
